# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SnapshotTestingHEIC is a Swift library that extends [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) to support HEIC image format for snapshot tests. HEIC provides comparable image quality to PNG with smaller file sizes.

## Build Commands

```bash
# Build for iOS
xcodebuild -scheme SnapshotTestingHEIC -destination 'generic/platform=iOS'

# Build for macOS
xcodebuild -scheme SnapshotTestingHEIC -destination 'platform=macOS'

# Build for tvOS
xcodebuild -scheme SnapshotTestingHEIC -destination 'generic/platform=tvOS'

# Run tests (requires simulator)
xcodebuild test -scheme SnapshotTestingHEIC -destination 'platform=iOS Simulator,name=iPhone 8'
```

## Architecture

### Core Components

- **CompressionQuality** (`Sources/SnapshotTestingHEIC/HEIC/CompressionQuality.swift`): Enum defining compression levels (lossless, low, medium, high, maximum, custom)

- **HEIC Conversion Extensions**:
  - `UIImage+HEIC.swift`: iOS/tvOS HEIC data conversion using `CGImageDestination`
  - `NSImage+HEIC.swift`: macOS HEIC data conversion

- **Snapshotting Strategies**: Each file provides `.imageHEIC` strategy for its respective type:
  - `UIImage.swift` / `NSImage.swift`: Core image diffing and snapshotting with pixel comparison
  - `UIView.swift` / `NSView.swift`: View snapshotting
  - `UIViewController.swift` / `NSViewController.swift`: View controller snapshotting
  - `SwiftUIView.swift`: SwiftUI view snapshotting

### Platform Support

The library uses conditional compilation extensively:
- `#if os(iOS) || os(tvOS)` for UIKit-based code
- `#if os(macOS)` for AppKit-based code
- `#if canImport(SwiftUI)` for SwiftUI support

### Testing

Tests use iPad Pro 12.9 as the standard device configuration. Snapshot files are stored in `Tests/SnapshotTestingHEICTests/__Snapshots__/`.
