// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "SnapshotTestingHEIC",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "SnapshotTestingHEIC",
            targets: ["SnapshotTestingHEIC"]),
    ],
    dependencies: [
        .package(name: "swift-snapshot-testing",
                 url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
                 from: "1.18.6"),
    ],
    targets: [
        .target(
            name: "SnapshotTestingHEIC",
            dependencies: [
                .product(name: "SnapshotTesting",
                         package: "swift-snapshot-testing"),
            ]
        ),
        .testTarget(
            name: "SnapshotTestingHEICTests",
            dependencies: ["SnapshotTestingHEIC"],
            exclude: ["__Snapshots__"]
        ),
    ]
)
