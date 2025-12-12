.PHONY: build release run clean xcode test help

# Default target
help:
	@echo "ClipKit Development Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build    - Build debug version"
	@echo "  release  - Build release version"
	@echo "  run      - Build and run the app"
	@echo "  test     - Run tests"
	@echo "  clean    - Clean build artifacts"
	@echo "  xcode    - Open project in Xcode (for signing/release)"
	@echo "  help     - Show this help message"

# Debug build
build:
	swift build

# Release build
release:
	swift build -c release

# Build and run
run: build
	./.build/debug/ClipKit

# Run tests
test:
	swift test

# Clean build artifacts
clean:
	swift package clean
	rm -rf .build

# Open in Xcode (required for code signing, entitlements, and App Store releases)
xcode:
	open ClipKit.xcodeproj
