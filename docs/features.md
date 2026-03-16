# Features

## Clipboard History

ClipKit automatically captures text and images copied to the clipboard. Items are displayed in a searchable, scrollable list.

- **Text and images** — Both text and TIFF image data are captured automatically
- **Duplicate detection** — Copying the same content moves it to the top instead of creating a duplicate. Duplicates are also checked against pinned items to prevent re-adding.
- **One-click restore** — Click any item to copy it back to your clipboard
- **Visual feedback** — The most recently copied item is highlighted in yellow; selected items are highlighted in blue with a flash animation on click

## Pinned Items

Save frequently used snippets as pinned items. Pinned items persist across app restarts and system reboots.

- **Configurable limit** — Store up to 50 pinned items (default: 12)
- **Drag & drop reordering** — Arrange pinned items in your preferred order (available in "Most Recent" sort mode)
- **Persistent storage** — Pinned items are saved to disk and survive app updates
- **Unpin behavior** — Unpinning an item automatically moves it back to the top of your ephemeral history

## Ephemeral Items

Recent clipboard history is stored as ephemeral items for the current session.

- **Session-based** — Automatically cleared on system reboot (detected via system boot time)
- **Configurable limit** — Keep between 10 and 500 recent items (default: 100)

## Toolbar Controls

The toolbar at the top of ClipKit provides quick access to:

- **Sort mode** — Toggle between "Most Recent" and "Alphabetical" sorting
- **Type filter** — Segmented control to show All Types, Text Only, or Images Only
- **Group by type** — Toggle to group ephemeral items by content type (text vs images)
- **Search** — Real-time search field to filter items as you type

These preferences are persisted across app restarts.

## Settings

Settings are organized into three tabs: **General**, **Limits**, and **Shortcuts**.

| Setting | Range | Default |
|---------|-------|---------|
| Max pinned items | 1–50 | 12 |
| Max ephemeral items | 10–500 | 100 |
| Polling interval | 0.1s, 0.25s, 0.5s, 1.0s, 2.0s | 0.5s |
| Launch at Login | On/Off | Off |
| Clear history on quit | On/Off | Off |
| Global shortcut | Configurable | Cmd+Shift+V |

!!! note
    Faster polling intervals detect clipboard changes more quickly but use more resources. Older items are automatically removed when limits are exceeded.
