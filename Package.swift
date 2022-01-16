// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "SnapshotTestingHEIC",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_10),
        .tvOS(.v10)
    ],
    products: [
        .library(
            name: "SnapshotTestingHEIC",
            targets: ["SnapshotTestingHEIC"]),
    ],
    dependencies: [
        .package(name: "SnapshotTesting",
                 url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
                 from: "1.8.0"),
    ],
    targets: [
        .target(
            name: "SnapshotTestingHEIC",
            dependencies: [
                .product(name: "SnapshotTesting",
                         package: "SnapshotTesting"),
            ]
        ),
        .testTarget(
            name: "SnapshotTestingHEICTests",
            dependencies: ["SnapshotTestingHEIC"],
            exclude: ["__Snapshots__"]
        ),
    ]
)
