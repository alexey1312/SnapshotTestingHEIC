#!/usr/bin/env bash

set -o pipefail && xcodebuild \
    -scheme SnapshotTestingHEIC \
    -destination 'generic/platform=iOS'
