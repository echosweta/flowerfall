import AppKit
import QuartzCore

// MARK: - Messages & settings

struct Message: Decodable {
    var cmd: String            // configure | burst | quit
    var count: Double?         // flowers per sprinkle, per screen
    var speed: Double?         // 1.0 = normal
    var size: Double?          // 1.0 = normal
    var opacity: Double?       // 0...1
    var emoji: String?         // e.g. "🌸"
    var duration: Double?      // seconds each flower stays visible
}

struct Settings {
    var count = 14.0
    var speed = 1.0
    var size = 1.0
    var opacity = 1.0
    var emoji = "🌸"
    var duration = 2.0
}

// Flowers are emitted for half a second; each one then lives `duration` seconds.
let emitSeconds = 0.5

// MARK: - Emoji image

func makeEmojiImage(_ emoji: String) -> CGImage {
    let side: CGFloat = 128
    let image = NSImage(size: NSSize(width: side, height: side), flipped: false) { rect in
        let font = NSFont(name: "Apple Color Emoji", size: 100) ?? NSFont.systemFont(ofSize: 100)
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let str = emoji as NSString
        let sz = str.size(withAttributes: attrs)
        str.draw(at: NSPoint(x: (rect.width - sz.width) / 2,
                             y: (rect.height - sz.height) / 2),
                 withAttributes: attrs)
        return true
    }
    var r = CGRect(x: 0, y: 0, width: side, height: side)
    return image.cgImage(forProposedRect: &r, context: nil, hints: nil)!
}

// MARK: - Overlay window (transparent + click-through)

final class OverlayWindow: NSWindow {
    let emitter = CAEmitterLayer()

    init(screen: NSScreen) {
        super.init(contentRect: screen.frame,
                   styleMask: .borderless,
                   backing: .buffered,
                   defer: false)
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = true            // clicks pass through
        level = .screenSaver                 // above normal windows
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary,
                              .stationary, .ignoresCycle]
        isReleasedWhenClosed = false

        let view = NSView(frame: NSRect(origin: .zero, size: screen.frame.size))
        view.wantsLayer = true
        view.layer?.addSublayer(emitter)
        contentView = view
        setFrame(screen.frame, display: false)
        emitter.birthRate = 0                // silent until a burst
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    func apply(_ s: Settings, image: CGImage) {
        let size = contentView?.bounds.size ?? frame.size
        let h = size.height
        let speed = CGFloat(max(0.2, s.speed))
        let life = max(0.5, s.duration)
        let v0 = 0.1 * h
        // gravity chosen so a flower falls ~65% of the screen during its life
        let gravity = max(0, 2 * (0.65 * h - v0 * CGFloat(life)) / CGFloat(life * life))

        emitter.frame = CGRect(origin: .zero, size: size)
        emitter.emitterShape = .line
        emitter.emitterPosition = CGPoint(x: size.width / 2, y: h + 10)
        emitter.emitterSize = CGSize(width: size.width, height: 1)
        emitter.renderMode = .unordered
        emitter.opacity = Float(max(0, min(1, s.opacity)))

        let c = CAEmitterCell()
        c.contents = image
        c.birthRate = Float(max(1, s.count) / emitSeconds)
        c.lifetime = Float(life)
        c.lifetimeRange = Float(life * 0.1)
        c.velocity = v0 * speed
        c.velocityRange = 0.05 * h
        c.emissionLongitude = -.pi / 2          // down (macOS layers: +y is up)
        c.emissionRange = .pi / 6
        c.yAcceleration = -gravity * speed      // gravity: sprinkle speeds up as it falls
        c.spin = 0
        c.spinRange = 2
        c.scale = CGFloat(0.3 * s.size)
        c.scaleRange = CGFloat(0.1 * s.size)
        c.alphaSpeed = Float(-1.0 / life)       // fade out over its life
        emitter.emitterCells = [c]
    }
}

// MARK: - Controller

final class Controller {
    var settings = Settings()
    var windows: [OverlayWindow] = []
    var image = makeEmojiImage(Settings().emoji)
    var generation = 0

    init() {
        rebuild()
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil, queue: .main
        ) { [weak self] _ in self?.rebuild() }
    }

    func rebuild() {
        windows.forEach { $0.orderOut(nil); $0.close() }
        windows = NSScreen.screens.map { OverlayWindow(screen: $0) }
        windows.forEach {
            $0.apply(settings, image: image)
            $0.orderFrontRegardless()
        }
    }

    func refresh() {
        windows.forEach { $0.apply(settings, image: image) }
    }

    func burst() {
        generation += 1
        let g = generation
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        windows.forEach { $0.emitter.birthRate = 1 }
        CATransaction.commit()
        DispatchQueue.main.asyncAfter(deadline: .now() + emitSeconds) { [weak self] in
            guard let self = self, self.generation == g else { return }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.windows.forEach { $0.emitter.birthRate = 0 }
            CATransaction.commit()
        }
    }

    func handle(_ m: Message) {
        switch m.cmd {
        case "configure":
            if let v = m.count { settings.count = v }
            if let v = m.speed { settings.speed = v }
            if let v = m.size { settings.size = v }
            if let v = m.opacity { settings.opacity = v }
            if let v = m.duration { settings.duration = v }
            if let v = m.emoji, !v.isEmpty, v != settings.emoji {
                settings.emoji = v
                image = makeEmojiImage(v)
            }
            refresh()
        case "burst":
            burst()
        case "quit":
            NSApp.terminate(nil)
        default:
            break
        }
    }
}

// MARK: - Entry point

let app = NSApplication.shared
app.setActivationPolicy(.accessory)        // no Dock icon, no menu bar

let controller = Controller()

// Read JSON lines from stdin; exit when the extension goes away.
Thread.detachNewThread {
    while let line = readLine() {
        guard let data = line.data(using: .utf8),
              let msg = try? JSONDecoder().decode(Message.self, from: data)
        else { continue }
        DispatchQueue.main.async { controller.handle(msg) }
    }
    DispatchQueue.main.async { NSApp.terminate(nil) }
}

app.run()
