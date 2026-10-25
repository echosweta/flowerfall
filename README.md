# Flowerfall

A 2-second sprinkle of pink flower emoji (🌸) over your screen when a command **succeeds (exit code 0) in VS Code's integrated terminal**. Failed commands do nothing. The overlay is transparent and click-through, and it closes itself afterwards.

## Quick start (Mac)

1. `cd` into this folder in Terminal.
2. `bash scripts/setup.sh`
3. `npm run package` -> creates `flowerfall-0.3.1.vsix`
4. VS Code > Extensions (Shift+Cmd+X) > ... > Install from VSIX... > restart VS Code.
5. Cmd+Shift+P > **Flowerfall: Sprinkle now** to test.
6. Open Terminal > New Terminal inside VS Code and run a command that succeeds, e.g. `node -v`.

## Settings (Cmd+, then search "flowerfall")

`mode`, `emoji`, `count`, `size`, `speed`, `opacity`, `ignoreCommands`.

## Troubleshooting

- Nothing on terminal success: enable Settings > Terminal > Integrated > Shell Integration: Enabled, then open a new terminal.
- macOS blocks the helper: `xattr -d com.apple.quarantine "$HOME/.vscode/extensions/"*flowerfall*/bin/FlowerfallHelper`
