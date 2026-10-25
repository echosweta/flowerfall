import * as vscode from 'vscode';
import * as cp from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

let helper: cp.ChildProcessWithoutNullStreams | undefined;
let log: vscode.OutputChannel;
let stopTimer: NodeJS.Timeout | undefined;

// Flowers are emitted for 0.5s, then live `duration` seconds; close the helper a bit after.
const EMIT_MS = 500;

function cfg() {
  return vscode.workspace.getConfiguration('flowerfall');
}

function readConfig() {
  const c = cfg();
  return {
    cmd: 'configure',
    count: c.get<number>('count', 14),
    speed: c.get<number>('speed', 1),
    size: c.get<number>('size', 1),
    opacity: c.get<number>('opacity', 1),
    duration: c.get<number>('duration', 2),
    emoji: c.get<string>('emoji', '🌸') || '🌸'
  };
}

function send(msg: object) {
  if (helper && helper.stdin.writable) {
    helper.stdin.write(JSON.stringify(msg) + '\n');
  }
}

function spawnHelper(ctx: vscode.ExtensionContext): boolean {
  if (helper) { return true; }
  if (process.platform !== 'darwin') {
    vscode.window.showWarningMessage('Flowerfall overlay only works on macOS.');
    return false;
  }
  const bin = ctx.asAbsolutePath(path.join('bin', 'FlowerfallHelper'));
  if (!fs.existsSync(bin)) {
    vscode.window.showErrorMessage('Flowerfall helper not built. Run "npm run build:helper" first.');
    return false;
  }
  try { fs.chmodSync(bin, 0o755); } catch { /* ignore */ }

  const child = cp.spawn(bin, [], { stdio: ['pipe', 'pipe', 'pipe'] });
  helper = child;
  child.stdin.on('error', () => { /* helper closed; ignore EPIPE */ });
  child.stdout.on('data', d => log.append(d.toString()));
  child.stderr.on('data', d => log.append(d.toString()));
  child.on('error', err => {
    vscode.window.showErrorMessage(`Flowerfall failed to start: ${err.message}`);
    if (helper === child) { helper = undefined; }
  });
  child.on('exit', () => {
    if (helper === child) { helper = undefined; }
  });
  return true;
}

export function stopFlowerfall() {
  if (stopTimer) { clearTimeout(stopTimer); stopTimer = undefined; }
  if (!helper) { return; }
  const child = helper;
  helper = undefined;
  try { child.stdin.write(JSON.stringify({ cmd: 'quit' }) + '\n'); } catch { /* ignore */ }
  setTimeout(() => { if (!child.killed) { child.kill(); } }, 1000);
}

/** A ~2 second sprinkle of flowers, then everything closes. */
export function sprinkle(ctx: vscode.ExtensionContext) {
  if (stopTimer) { clearTimeout(stopTimer); stopTimer = undefined; }
  if (!spawnHelper(ctx)) { return; }
  send(readConfig());
  send({ cmd: 'burst' });
  const life = Math.max(0.5, cfg().get<number>('duration', 2)) * 1000;
  stopTimer = setTimeout(() => stopFlowerfall(), EMIT_MS + life * 1.1 + 500);
}

export function activateFlowerfall(ctx: vscode.ExtensionContext) {
  log = vscode.window.createOutputChannel('Flowerfall');

  ctx.subscriptions.push(
    log,
    vscode.commands.registerCommand('flowerfall.test', () => sprinkle(ctx)),
    // Fires whenever a command finishes in a VS Code terminal (needs shell integration, on by default).
    vscode.window.onDidEndTerminalShellExecution(e => {
      if (cfg().get<string>('mode', 'onTerminalSuccess') !== 'onTerminalSuccess') { return; }
      if (e.exitCode !== 0) { return; }          // failed or unknown -> no flowers
      const line = (e.execution.commandLine.value || '').trim();
      const first = line.split(/\s+/)[0];
      if (!line || cfg().get<string[]>('ignoreCommands', []).includes(first)) { return; }
      sprinkle(ctx);
    })
  );
}
