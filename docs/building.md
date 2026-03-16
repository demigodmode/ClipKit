# Building from Source

## Requirements

- macOS 13.0+
- Xcode 15+
- Swift 5.9+

## Quick Start

```bash
git clone https://github.com/demigodmode/ClipKit.git
cd ClipKit

# Build and run
make run

# Or open in Xcode
make xcode
```

## Make Commands

| Command | Description |
|---------|-------------|
| `make build` | Build debug version |
| `make release` | Build release version |
| `make run` | Build and run |
| `make test` | Run tests |
| `make clean` | Clean build artifacts |
| `make xcode` | Open in Xcode |

## Swift Package Manager

```bash
swift build             # Debug build
swift build -c release  # Release build
swift run               # Run the app
swift test              # Run tests
swift package clean     # Clean
```

## SPM vs Xcode

SPM builds work for day-to-day development, but have some limitations:

| Feature | SPM | Xcode |
|---------|-----|-------|
| Code signing | No | Yes |
| Entitlements | No | Yes |
| App bundle structure | Basic executable | Full `.app` bundle |
| Distribution | Dev only | App Store, TestFlight |

**Use Xcode when you need to:**

- Build for App Store or TestFlight distribution
- Configure code signing and entitlements
- Profile with Instruments
- Access sandbox-protected APIs

**Use SPM/VSCode for:**

- Day-to-day development
- Quick iteration and testing
- CI/CD pipelines

## VSCode Setup

1. Install the [Swift extension](https://marketplace.visualstudio.com/items?itemName=sswg.swift-lang)
2. Install [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb) for debugging
3. Open the project folder in VSCode
4. Use `Cmd+Shift+B` to build, `F5` to debug
