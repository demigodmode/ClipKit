# Contributing

Contributions to ClipKit are welcome! Here's how to get started.

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/ClipKit.git
   cd ClipKit
   ```
3. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. Make your changes and run tests:
   ```bash
   make test
   ```
5. Push and open a pull request

## Development Setup

See [Building from Source](building.md) for build instructions and IDE setup.

## Testing

ClipKit uses Swift's native `Testing` framework (not XCTest). Run the test suite with:

```bash
make test
# or
swift test
```

When adding new features, include tests that cover the expected behavior. Tests live in `ClipKitTests/`.

## Guidelines

- **No regressions** — Existing functionality must continue to work
- **Test new features** — Add tests for any new behavior
- **Keep it focused** — ClipKit aims to do less, better. Avoid scope creep.
- **Preserve user data** — Never break backward compatibility with stored data. Use the migration pattern described in [Architecture](architecture.md#data-format-migration).

## Reporting Issues

File issues on the [GitHub issue tracker](https://github.com/demigodmode/ClipKit/issues). Include:

- macOS version
- ClipKit version
- Steps to reproduce
- Expected vs actual behavior
