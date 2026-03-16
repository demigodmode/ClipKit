# Roadmap

ClipKit's goal is to become the best lightweight, privacy-first clipboard manager for macOS.

## Principles

- **Local-first** — No cloud required; user controls all data
- **Fast by default** — Low latency UI and minimal CPU/battery impact
- **Privacy-first** — Least-privilege, explicit opt-ins
- **Do less, better** — Ship a focused feature set, polished

## Performance Targets

- UI open latency < 150ms
- Pasteboard polling overhead < 1% CPU
- Zero data loss across updates

## v1.3: Stability & Distribution

*Table stakes for a real clipboard manager.*

- Menu bar mode — background agent, no Dock icon
- Homebrew Cask distribution (`brew install --cask clipkit`)
- Bug fixes and polish

## v1.4: UX Polish

*Daily usability improvements.*

- Preview/expand items — rich text, compact images
- Show source app metadata

## v1.5: Privacy Controls

*For users who copy sensitive data.*

- Per-app exclusions (ignore password managers, etc.)
- Pause capture hotkey

## v2.0: Sync (If Demand Exists)

*Only if users request it.*

- iCloud sync for pinned items (opt-in, encrypted)
- Conflict resolution

## Deferred Ideas

These are not planned but may be revisited based on user demand:

| Idea | Why Deferred |
|------|-------------|
| SQLite storage | JSON works fine for <1000 items |
| Snippets/templates | Scope creep — not a text expander |
| CLI tool | Niche audience |
| Plugin architecture | Maintenance burden |
| Encryption at rest | Most users don't need it |
| More data types (files, etc.) | Text + images covers 99% of use |

## Feature Requests

Have an idea? Open an issue on the [GitHub issue tracker](https://github.com/demigodmode/ClipKit/issues).
