import * as vscode from 'vscode';
import { activateFlowerfall, stopFlowerfall } from './flowerfall';

export function activate(ctx: vscode.ExtensionContext) {
  activateFlowerfall(ctx);
}

export function deactivate() {
  stopFlowerfall();
}
