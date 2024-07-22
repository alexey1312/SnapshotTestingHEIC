# 🗜 SnapshotTestingHEIC

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Falexey1312%2FSnapshotTestingHEIC%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/alexey1312/SnapshotTestingHEIC)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Falexey1312%2FSnapshotTestingHEIC%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/alexey1312/SnapshotTestingHEIC)
[![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Falexey1312%2FSnapshotTestingHEIC%2Fbadge&style=flat)](https://actions-badge.atrox.dev/alexey1312/SnapshotTestingHEIC/goto)

An extension to [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) which allows you to create HEIC images.
The benefit of using HEIC instead of PNG is that it can store as much as image quality as PNG, but with a smaller file size.
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
    assertSnapshot(matching: vc, as: .imageHEIC)
  }
}
```

## Installation

### Xcode 11

> ⚠️ Warning: By default, Xcode will try to add the SnapshotTestingHEIC package to your project's main application/framework target. Please ensure that SnapshotTestingHEIC is added to a _test_ target instead, as documented in the last step, below.
 1. From the **File** menu, navigate through **Swift Packages** and select **Add Package Dependency…**.
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
