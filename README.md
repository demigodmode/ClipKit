# ClipKit

A lightweight clipboard manager for macOS built with SwiftUI.

## Features

- **Clipboard History** - Automatically captures text and images copied to the clipboard
- **Pinned Items** - Save frequently used snippets (up to 12) that persist across reboots
- **Ephemeral Storage** - Recent clipboard items are stored for the current session and cleared on reboot
- **Search** - Filter clipboard history with real-time search
- **Sorting** - Sort items by most recent or alphabetically
- **Type Filtering** - Filter by text only, images only, or show all
- **One-Click Restore** - Click any item to copy it back to the clipboard

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

## Building from Source

Requirements:
- macOS 13.0 or later
- Xcode 15+ (for building)
- Swift 5.9+

### Using Make

```bash
make build      # Build debug version
make release    # Build release version
make run        # Build and run
make test       # Run tests
make clean      # Clean build artifacts
make xcode      # Open in Xcode
```

### Using Swift Package Manager

```bash
swift build             # Debug build
swift build -c release  # Release build
swift run               # Run the app
swift test              # Run tests
```

### Using Xcode

```bash
open ClipKit.xcodeproj
```

Use Xcode for code signing, entitlements, and App Store distribution.

## Architecture

ClipKit uses a simple architecture with SwiftUI and JSON-based persistence:

- **ClipboardManager** - Polls the system clipboard every 0.5s and maintains two lists:
  - `ephemeralItems` - Session-based history, tied to system boot time
  - `pinnedItems` - Persistent favorites stored in Application Support

- **ClipboardContent** - Enum representing clipboard data (text or image)

- **ContentView** - Main UI with toolbar controls and two List sections

Data is persisted as JSON files in `~/Library/Application Support/`.

## License

MIT
