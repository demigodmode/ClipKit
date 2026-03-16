# Architecture

ClipKit is built with SwiftUI and uses JSON-based persistence.

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| [HotKey](https://github.com/soffes/HotKey) | 0.2.0+ | Global keyboard shortcut registration |

## Core Components

| Component | Purpose |
|-----------|---------|
| **ClipKitApp** | App entry point. Creates `ClipboardManager` as `@StateObject` and injects via `@EnvironmentObject`. Provides a Help menu item. |
| **ClipboardManager** | Central state management. Polls the system clipboard, maintains ephemeral and pinned lists, handles persistence. |
| **SettingsManager** | App preferences via `@AppStorage`. Persists UI state (sort mode, filter, grouping) across launches. Publishes polling interval changes via `PassthroughSubject`. |
| **GlobalShortcutManager** | Registers the global hotkey using the HotKey library. |
| **ClipboardContent** | Enum with `.text(String)` and `.image(Data)` cases. Implements `Codable` for JSON persistence. |
| **ContentView** | Main UI with toolbar controls and two list sections (pinned + ephemeral). |
| **LaunchAtLoginHelper** | Wraps `SMAppService` (macOS 13+) for launch-at-login functionality. |
| **AccessibilityHelper** | Checks accessibility permissions and can prompt/deep-link to System Settings. |
| **HelpView** | In-app help dialog with feature overview and shortcut reference. |

## Data Flow

```
System Clipboard
       |
       v
  Timer (0.5s polling)
       |
       v
  ClipboardManager
   /          \
  v            v
Ephemeral    Pinned
Items        Items
  |            |
  v            v
ephemeral   pinnedItems
Items.json  .json
```

1. A timer polls `NSPasteboard.general` every 0.5 seconds for new content
2. New content is inserted at the front of `ephemeralItems`
3. Duplicate detection: if content already exists, it's moved to the top instead of duplicated
4. Users can pin items, moving them from ephemeral to pinned storage
5. Clicking an item calls `restoreToPasteboard()` to copy it back to the system clipboard
6. Pinned items can be reordered via drag-and-drop (in "Most Recent" sort mode)

## Data Storage

User data is stored in `~/Library/Application Support/`, **separate from the app bundle**:

```
~/Library/Application Support/
├── pinnedItems.json      # Persistent across reboots
└── ephemeralItems.json   # Cleared on reboot
```

This separation means:

- Updating or reinstalling the app preserves all user data
- Ephemeral items are tied to boot time and discarded on reboot
- Pinned items persist indefinitely

### Boot Time Detection

ClipKit uses `sysctl` with `KERN_BOOTTIME` to read the system's last boot timestamp. On launch, if the stored boot time differs from the current one, all ephemeral items are cleared. This ensures session-based items don't survive a reboot without requiring a background daemon.

### Data Format Migration

When changing the JSON format, ClipKit uses a forward-compatible migration pattern:

1. Try decoding the new format first
2. Fall back to the old format and migrate if needed
3. Save in the new format after successful migration

This ensures users never lose data during app updates.
