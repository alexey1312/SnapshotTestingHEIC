# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SnapshotTestingHEIC is a Swift library that extends [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) to support HEIC image format for snapshot tests. HEIC provides comparable image quality to PNG with smaller file sizes.

Minimum Swift version: 5.2. Supports iOS 13+, macOS 10.15+, tvOS 13+.

## Build Commands

```bash
# Build using Swift Package Manager
swift build

# Run tests (macOS/Linux - matches CI)
swift test

# Run a single test
swift test --filter SnapshotTestingHEICTests.test_CompressionQuality_rawValues

# Build for iOS
xcodebuild -scheme SnapshotTestingHEIC -destination 'generic/platform=iOS'

# Build for macOS
xcodebuild -scheme SnapshotTestingHEIC -destination 'platform=macOS'

# Build for tvOS
xcodebuild -scheme SnapshotTestingHEIC -destination 'generic/platform=tvOS'

# Run tests on iOS Simulator (MUST use iPad Pro 12.9 - snapshots are recorded for this device)
xcodebuild test -scheme SnapshotTestingHEIC -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)'
```

## Architecture

### Core Components

- **CompressionQuality** (`Sources/SnapshotTestingHEIC/HEIC/CompressionQuality.swift`): Enum defining compression levels (lossless, low, medium, high, maximum, custom)

- **OpaqueMode** (`Sources/SnapshotTestingHEIC/HEIC/OpaqueMode.swift`): Enum controlling alpha channel handling (.auto, .opaque, .transparent)

- **HEIC Conversion Extensions**:
  - `UIImage+HEIC.swift`: iOS/tvOS HEIC data conversion using `CGImageDestination`
  - `NSImage+HEIC.swift`: macOS HEIC data conversion
  - Both use `CompressionQuality` enum for type-safe compression settings

- **ImageComparisonHelpers** (`Sources/SnapshotTestingHEIC/ImageComparisonHelpers.swift`): Shared utilities for pixel comparison across platforms:
  - `comparePixelBytes()`: Byte-level comparison with early exit optimization
  - `createImageContext()`: CGContext creation with consistent sRGB color space
  - Constants: `imageContextColorSpace`, `imageContextBitsPerComponent`, `imageContextBytesPerPixel`

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

**CI uses `swift test`** which runs on both macOS and Linux. The reference snapshots are generated for macOS. macOS tests skip on systems without HEIC encoding support (e.g., GitHub Actions runners) using `isHEICEncodingAvailable()`.

iOS tests use iPad Pro 12.9 (`.iPadPro12_9`) as the device configuration. **Running on other devices will fail** due to resolution mismatch. These run locally via xcodebuild, not on CI.

Snapshot files are stored in `Tests/SnapshotTestingHEICTests/__Snapshots__/`.

To re-record snapshots, temporarily add to the test class:
```swift
override func invokeTest() {
    withSnapshotTesting(record: .all) {
        super.invokeTest()
    }
}
```

### Known Warnings

XCTest may produce warnings like `'xctest' is trying to save an opaque image with 'AlphaLast'` when saving attachments to xcresult. This is internal XCTest behavior and cannot be suppressed by the library.
