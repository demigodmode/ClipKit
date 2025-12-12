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

## Requirements

- macOS 13.0 or later
- Xcode 15+ (for building)
- Swift 5.9+

## Building

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
