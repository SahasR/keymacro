# KeyMacro

A lightweight macOS menu bar app for running multi-step automation macros triggered by global hotkeys.

## What it does

Assign a hotkey to a macro, and KeyMacro will execute a sequence of actions whenever you press it — from any app, system-wide.

**Action steps:**

| Step | Description |
|---|---|
| Type Text | Simulates keyboard input of a string |
| Paste | Pastes text via the clipboard |
| Press Key | Sends a specific key + modifier combination |
| Delay | Waits a given number of milliseconds |
| Shell | Runs a shell command; optionally types its output |
| Open URL | Opens a URL in the default browser |
| Set Clipboard | Writes text to the clipboard |

## Requirements

- macOS 13.0+
- Apple Silicon (arm64)
- Xcode command-line tools (`xcode-select --install`)
- Accessibility permission (prompted on first launch)

## Install

Download the latest `KeyMacro.dmg` from [Releases](https://github.com/SahasR/keymacro/releases), open it, and drag KeyMacro to Applications.

## Build from source

```bash
make build       # compile → build/KeyMacro.app
make run         # build and launch
make dmg         # build + package → build/KeyMacro.dmg
make clean       # remove build/
make reset       # kill app, wipe data, revoke accessibility permission
```

## Usage

1. Launch KeyMacro — it appears in the menu bar.
2. Grant Accessibility access when prompted (required for key simulation).
3. Open Settings, go to **Macros**, and click **+** to create a macro.
4. Record a hotkey, add action steps, and save.
5. Press the hotkey from anywhere to run the macro.
