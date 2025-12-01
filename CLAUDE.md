# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SnapshotTestingHEIC is a Swift library that extends [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) to support HEIC image format for snapshot tests. HEIC provides comparable image quality to PNG with smaller file sizes.

## Build Commands

```bash
# Build using Swift Package Manager
swift build

# Run tests (macOS - matches CI)
swift test

# Build for iOS
xcodebuild -scheme SnapshotTestingHEIC -destination 'generic/platform=iOS'

# Build for macOS
xcodebuild -scheme SnapshotTestingHEIC -destination 'platform=macOS'

# Build for tvOS
xcodebuild -scheme SnapshotTestingHEIC -destination 'generic/platform=tvOS'

# Run tests on iOS Simulator
xcodebuild test -scheme SnapshotTestingHEIC -destination 'platform=iOS Simulator,name=iPhone 16'
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

**CI uses `swift test`** which runs macOS tests only. The reference snapshots are generated for macOS.

iOS tests use iPad Pro 12.9 as the device configuration, but these run locally via xcodebuild, not on CI.

Snapshot files are stored in `Tests/SnapshotTestingHEICTests/__Snapshots__/`.

To re-record snapshots, temporarily add to the test class:
```swift
override func invokeTest() {
    withSnapshotTesting(record: .all) {
        super.invokeTest()
    }
}
```
