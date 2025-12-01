# 🗜 SnapshotTestingHEIC

[![GitHub stars](https://img.shields.io/github/stars/alexey1312/SnapshotTestingHEIC?style=social)](https://github.com/alexey1312/SnapshotTestingHEIC)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Falexey1312%2FSnapshotTestingHEIC%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/alexey1312/SnapshotTestingHEIC)
[![Swift-versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Falexey1312%2FSnapshotTestingHEIC%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/alexey1312/SnapshotTestingHEIC)
[![CI](https://github.com/alexey1312/SnapshotTestingHEIC/actions/workflows/ci.yml/badge.svg)](https://github.com/alexey1312/SnapshotTestingHEIC/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/alexey1312/SnapshotTestingHEIC.svg)](LICENSE.md)

An extension to [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) which allows you to create HEIC images.
The benefit of using HEIC instead of PNG is that it can store as much as image quality as PNG, but with a smaller file size.

## File Size Comparison

Real-world comparison using a complex UI layout (500x600 profile screen with gradients, shadows, cards, and text):

| Format | Size | Savings |
|--------|------|---------|
| PNG | 443 KB | - |
| HEIC Lossless | 165 KB | **63% smaller** |
| HEIC Medium | 31 KB | **93% smaller** |
| HEIC Maximum (lossy) | 8 KB | **98% smaller** |

You can verify this by looking at [SnapshotTestingHEICTests](Tests/SnapshotTestingHEICTests/__Snapshots__/SnapshotTestingHEICTests).

## Usage

Once [installed](#installation), _no additional configuration is required_. You can import the `SnapshotTestingHEIC` module, call `SnapshotTesting` following their usage guide and simply provide our `imageHEIC` strategy as below.

```swift
import XCTest
import SnapshotTesting
import SnapshotTestingHEIC

class MyViewControllerTests: XCTestCase {
  func testMyViewController() {
    let vc = MyViewController()

    // Default (lossless quality)
    assertSnapshot(of: vc, as: .imageHEIC)

    // With compression quality options
    assertSnapshot(of: vc, as: .imageHEIC(compressionQuality: .lossless))  // Best quality, ~63% smaller than PNG
    assertSnapshot(of: vc, as: .imageHEIC(compressionQuality: .medium))    // Good quality, ~93% smaller than PNG
    assertSnapshot(of: vc, as: .imageHEIC(compressionQuality: .maximum))   // Smallest size, ~98% smaller than PNG
  }
}
```

### Compression Quality Options

| Option | Description |
|--------|-------------|
| `.lossless` | Best quality, no compression artifacts (default) |
| `.low` | Minimal compression |
| `.medium` | Balanced quality and size |
| `.high` | Higher compression |
| `.maximum` | Smallest file size, some quality loss |
| `.custom(Double)` | Custom quality value (0.0 - 1.0) |

## Installation

### Xcode 11+

> Warning: By default, Xcode will try to add the SnapshotTestingHEIC package to your project's main application/framework target. Please ensure that SnapshotTestingHEIC is added to a _test_ target instead, as documented in the last step, below.
 1. From the **File** menu, navigate through **Swift Packages** and select **Add Package Dependency...**.
 2. Enter package repository URL: `https://github.com/alexey1312/SnapshotTestingHEIC`
 3. Confirm the version and let Xcode resolve the package
 4. On the final dialog, update SnapshotTestingHEIC's **Add to Target** column to a test target that will contain snapshot tests (if you have more than one test target, you can later add SnapshotTestingHEIC to them by manually linking the library in its build phase)

### Swift Package Manager

If you want to use SnapshotTestingHEIC in any other project that uses [Swift Package Manager](https://swift.org/package-manager/), add the package as a dependency in `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/alexey1312/SnapshotTestingHEIC.git", from: "1.0.0"),
]
```

Next, add `SnapshotTestingHEIC` as a dependency of your test target:

```swift
targets: [
  .target(
    name: "MyApp"
  ),

  .testTarget(
    name: "MyAppTests",
    dependencies: [
      .target(name: "MyApp"),
      .product(name: "SnapshotTestingHEIC", package: "SnapshotTestingHEIC"),
    ]
  ),
]
```

### Other

We do not currently support distribution through CocoaPods or Carthage.

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
