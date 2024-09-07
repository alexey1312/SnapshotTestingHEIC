#!/usr/bin/env bash

set -o pipefail && xcodebuild \
    -workspace .swiftpm/xcode/package.xcworkspace \
    -scheme SnapshotTestingHEIC \
    -destination 'generic/platform=iOS'
