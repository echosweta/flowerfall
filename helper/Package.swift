// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FlowerfallHelper",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "FlowerfallHelper",
            path: "Sources/FlowerfallHelper"
        )
    ]
)
