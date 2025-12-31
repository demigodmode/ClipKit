# ClipKit

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue)](https://www.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange)](https://swift.org)
[![License](https://img.shields.io/badge/License-GPL--3.0-green)](LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/demigodmode/ClipKit)](https://github.com/demigodmode/ClipKit/releases/latest)

A lightweight clipboard manager for macOS built with SwiftUI.

---

## Features

### Core
- **Clipboard History** - Automatically captures text and images copied to the clipboard
- **Pinned Items** - Save frequently used snippets that persist across reboots
- **Ephemeral Storage** - Recent clipboard items stored for current session, cleared on reboot
- **Duplicate Detection** - Copying same content moves it to top instead of creating duplicates
- **Search** - Filter clipboard history with real-time search
- **Sorting** - Sort items by most recent or alphabetically
- **Type Filtering** - Filter by text only, images only, or show all
- **One-Click Restore** - Click any item to copy it back to the clipboard
- **Drag & Drop Reordering** - Reorder pinned items by dragging

### Settings (v1.2.0)
- **Configurable Limits** - Adjust max pinned items (1-50), max ephemeral items (10-500), polling interval
- **Launch at Login** - Keep ClipKit always available in the background
- **Clear History on Quit** - Privacy option to clear ephemeral items when quitting

### Keyboard Shortcuts (v1.2.0)

#### Global Shortcut
| Shortcut | Action |
|----------|--------|
| ⌘⇧V | Show/Hide ClipKit (configurable) |

> **Note:** Global shortcut requires Accessibility permission. Enable "Launch at Login" for always-available access.

#### In-App Shortcuts
| Shortcut | Action |
|----------|--------|
| ↑ / ↓ | Navigate items |
| Return | Copy selected item |
| Delete | Remove selected item |
| P | Pin/unpin selected item |
| Escape | Clear selection |

---

## Installation

### First Time Install

1. Go to [Releases](https://github.com/demigodmode/ClipKit/releases/latest)
2. Under "Assets", click `ClipKit.zip` to download
3. Open your Downloads folder and double-click `ClipKit.zip` to unzip
4. Drag `ClipKit.app` into your Applications folder
5. Double-click to launch
6. If macOS says "ClipKit can't be opened", go to System Settings > Privacy & Security and click "Open Anyway"

### Updating to a New Version

1. Quit ClipKit if it's running (right-click the dock icon > Quit)
2. Download the new `ClipKit.zip` from [Releases](https://github.com/demigodmode/ClipKit/releases/latest)
3. Unzip and drag `ClipKit.app` to Applications
4. Click "Replace" when prompted
5. Launch the updated app

---

## Building from Source

### Requirements
- macOS 13.0+
- Xcode 15+
- Swift 5.9+

### Quick Start

```bash
# Clone
git clone https://github.com/demigodmode/ClipKit.git
cd ClipKit

# Build and run
make run

# Or open in Xcode
make xcode
```

### Make Commands

| Command | Description |
|---------|-------------|
| `make build` | Build debug version |
| `make release` | Build release version |
| `make run` | Build and run |
| `make test` | Run tests |
| `make clean` | Clean build artifacts |
| `make xcode` | Open in Xcode |

### Swift Package Manager

```bash
swift build             # Debug build
swift build -c release  # Release build
swift run               # Run the app
```

---

## Architecture

ClipKit uses SwiftUI with JSON-based persistence:

| Component | Purpose |
|-----------|---------|
| **ClipboardManager** | Polls system clipboard, maintains ephemeral + pinned lists |
| **SettingsManager** | Handles all app preferences via @AppStorage |
| **GlobalShortcutManager** | Registers global hotkey using HotKey library |
| **ClipboardContent** | Enum for clipboard data (text/image) |
| **ContentView** | Main UI with toolbar and list sections |

### Data Storage

```
~/Library/Application Support/
├── pinnedItems.json      # Persistent across reboots
└── ephemeralItems.json   # Cleared on reboot
```

---

## License

[GPL-3.0](LICENSE)
