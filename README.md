# Spring is here 🌸

**Your code works. Celebrate it with an emoji shower! ✨**

Spring is here is a customizable macOS overlay for VS Code that sprinkles your favorite emojis across your screen when a terminal command succeeds.

Not just flowers. 🌸 Hearts, ✨ sparkles, 🎉 confetti, 🦋 butterflies, 💖 hearts, or whatever matches your vibe.

**Your emoji. Your settings. Your celebration.**

## ✨ Features

- **🎨 Choose your emoji** — Customize the emoji used in your celebration.
- **🔢 Control the particle count** — Choose how many emojis appear on your screen.
- **⏱️ Customize the animation** — Adjust the size, speed, and opacity to your liking.
- **🖥️ Screen overlay** — Enjoy a transparent, click-through overlay that doesn't interrupt your workflow.
- **✅ Celebrate successful commands** — Trigger the effect when a terminal command exits successfully.
- **🚫 Ignore commands** — Configure commands that shouldn't trigger the celebration.
- **⚡ Lightweight and temporary** — The overlay appears briefly and then disappears automatically.

## 🌈 Make it yours

Want a shower of hearts instead of flowers? Done.

Prefer a subtle sprinkle of sparkles? Go for it.

Want hundreds of emojis flying across your screen? Customize the particle count.

Make your coding environment feel a little more like *you*.

## ⚙️ Customization

Open VS Code Settings with `Cmd + ,` and search for `flowerfall`.

| Setting | What it does |
|---|---|
| `mode` | Configure the extension's operating mode. |
| `emoji` | Choose the emoji used in the celebration. |
| `count` | Customize the number of particles. |
| `size` | Adjust the particle size. |
| `speed` | Adjust the animation speed. |
| `opacity` | Control the transparency of the particles. |
| `ignoreCommands` | Specify commands to ignore. |

The available settings and their supported values are defined by the extension.

## 🚀 Getting started

### 1. Install

Install the extension from Open VSX:

[**Spring is here — Open VSX**](https://open-vsx.org/extension/echosweta/spring-is-here)

### 2. Open a terminal

Open the integrated terminal in VS Code.

### 3. Run a successful command

For example:

```bash
node -v
```

When the command succeeds, enjoy your emoji shower! 🎉

### 4. Customize your experience

Open the Command Palette with `Cmd + Shift + P` and search for:

**Flowerfall: Sprinkle now**

You can use this command to test the effect.

Then open Settings and search for `flowerfall` to customize your emoji and animation preferences.

## 🍎 Platform support

The screen overlay uses a native macOS helper. The overlay functionality is designed for macOS, and other platforms may not support the same experience.

## 🛠️ Troubleshooting

### Nothing happens after a successful command

1. Open VS Code Settings.
2. Search for `terminal.integrated.shellIntegration.enabled`.
3. Ensure shell integration is enabled.
4. Open a new integrated terminal and run a successful command again.

### The overlay doesn't appear on macOS

macOS may block an unsigned or quarantined helper application.

If you trust the source and understand the implications, check the helper's macOS security status and follow the project's setup instructions before allowing it to run.

### The emoji shower doesn't match my settings

Open VS Code Settings, search for `flowerfall`, and verify your selected emoji, count, size, speed, and opacity.

## 💻 Development

Want to explore the code or contribute?

```bash
git clone https://github.com/echosweta/spring-is-here.git
cd spring-is-here
```

Follow the setup instructions in the repository to configure the native macOS helper and build the extension.

## 🤝 Contributing

Ideas, bug reports, and contributions are welcome!

If you have an idea that could make coding a little more joyful, feel free to open an issue or submit a pull request.

[**View the source code on GitHub**](https://github.com/echosweta/spring-is-here)

## 📄 License

This project is licensed under the MIT License.

---

Made with ☕, code, and a little bit of delulu. 🌸✨
