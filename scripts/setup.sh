#!/bin/bash
# One-shot setup for Mac beginners. Run from the project root:  bash scripts/setup.sh
set -e
cd "$(dirname "$0")/.."

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installing Apple command line tools (a popup will appear)..."
  xcode-select --install
  echo "Re-run this script after the install finishes."
  exit 1
fi
command -v node >/dev/null || { echo "Node.js not found. Install from https://nodejs.org"; exit 1; }

echo "==> Installing npm packages"
npm install
echo "==> Building Swift helper"
npm run build:helper
echo "==> Compiling TypeScript"
npm run compile
echo
echo "Done! Open this folder in VS Code and press F5."
