# ClipKit

**A lightweight, privacy-first clipboard manager for macOS.**

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange)](https://swift.org)
[![License](https://img.shields.io/badge/License-GPL--3.0-green)](https://github.com/demigodmode/ClipKit/blob/main/LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/demigodmode/ClipKit)](https://github.com/demigodmode/ClipKit/releases/latest)

---

## What is ClipKit?

ClipKit is a native macOS clipboard manager built with SwiftUI. It automatically captures text and images you copy, keeps a searchable history, and lets you pin frequently used snippets for quick access.

**Key principles:**

- **Local-first** — No cloud required. Your data stays on your Mac.
- **Privacy-first** — Least-privilege, explicit opt-ins. No telemetry.
- **Lightweight** — Minimal CPU and battery impact.
- **Fast** — UI open latency under 150ms.

## Quick Start

1. Download `ClipKit.zip` from the [latest release](https://github.com/demigodmode/ClipKit/releases/latest)
2. Unzip and drag `ClipKit.app` to your Applications folder
3. Launch ClipKit
4. Use **Cmd+Shift+V** to show/hide ClipKit at any time

For detailed installation instructions, see [Installation](installation.md).

## How It Works

ClipKit monitors your system clipboard and automatically saves anything you copy:

- **Ephemeral items** — Your recent clipboard history, cleared on reboot
- **Pinned items** — Saved snippets that persist across reboots

Click any item to copy it back to the clipboard. Pin items you use often so they're always available.

## Data Storage

Your data is stored locally in `~/Library/Application Support/`, separate from the app itself. This means your pinned items survive app updates and reinstalls.
