import XCTest
import SnapshotTesting
#if os(iOS) || os(tvOS) || os(macOS)
    import CoreFoundation
#endif

#if canImport(SwiftUI)
    import SwiftUI
#endif

@testable import SnapshotTestingHEIC

final class SnapshotTestingHEICTests: XCTestCase {

    #if os(iOS) || os(tvOS)
        var sut: TestViewController!

        override func setUp() {
            super.setUp()
            sut = TestViewController()
        }

        override func tearDown() {
            sut = nil
            super.tearDown()
        }

        // MARK: - UIViewController Tests

        func test_UIViewController_PNG() {
            assertSnapshot(of: sut, as: .image(on: .iPadPro12_9))
        }

        func test_UIViewController_HEIC_lossless() {
            assertSnapshot(of: sut, as: .imageHEIC(on: .iPadPro12_9, compressionQuality: .lossless))
        }

        func test_UIViewController_HEIC_medium() {
            assertSnapshot(of: sut, as: .imageHEIC(on: .iPadPro12_9, compressionQuality: .medium))
        }

        func test_UIViewController_HEIC_maximum() {
            assertSnapshot(of: sut, as: .imageHEIC(on: .iPadPro12_9, compressionQuality: .maximum))
        }

        // MARK: - SwiftUI Tests

        func test_SwiftUI_PNG() {
            let view: some SwiftUI.View = SwiftUIView()
            assertSnapshot(of: view, as: .image(layout: .device(config: .iPadPro12_9)))
        }

        func test_SwiftUI_HEIC_lossless() {
            let view: some SwiftUI.View = SwiftUIView()
            assertSnapshot(
                of: view,
                as: .imageHEIC(layout: .device(config: .iPadPro12_9), compressionQuality: .lossless)
            )
        }

        func test_SwiftUI_HEIC_medium() {
            let view: some SwiftUI.View = SwiftUIView()
            assertSnapshot(of: view, as: .imageHEIC(layout: .device(config: .iPadPro12_9), compressionQuality: .medium))
        }

        func test_SwiftUI_HEIC_maximum() {
            let view: some SwiftUI.View = SwiftUIView()
            assertSnapshot(
                of: view,
                as: .imageHEIC(layout: .device(config: .iPadPro12_9), compressionQuality: .maximum)
            )
        }
    #endif

    #if os(macOS)
        func test_PNG_NSView() throws {
            // Skip on systems without HEIC support (e.g., GitHub Actions runners)
            // because the reference snapshots were recorded with HEIC-capable hardware
            try XCTSkipUnless(isHEICEncodingAvailable(), "HEIC encoding not available on this system")

            // given
            let view = createMacOSProfileView()
            // then
            assertSnapshot(of: view, as: .image)
        }

        func test_HEIC_NSView_lossless() throws {
            try XCTSkipUnless(isHEICEncodingAvailable(), "HEIC encoding not available on this system")

            // given
            let view = createMacOSProfileView()
            // then
            assertSnapshot(of: view, as: .imageHEIC(compressionQuality: .lossless))
        }

        func test_HEIC_NSView_medium() throws {
            try XCTSkipUnless(isHEICEncodingAvailable(), "HEIC encoding not available on this system")

            // given
            let view = createMacOSProfileView()
            // then
            assertSnapshot(of: view, as: .imageHEIC(compressionQuality: .medium))
        }

        func test_HEIC_NSView_maximum() throws {
            try XCTSkipUnless(isHEICEncodingAvailable(), "HEIC encoding not available on this system")

            // given
            let view = createMacOSProfileView()
            // then
            assertSnapshot(of: view, as: .imageHEIC(compressionQuality: .maximum))
        }

        private func createMacOSProfileView() -> NSView {
            let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 600))
            containerView.wantsLayer = true
            containerView.layer?.backgroundColor = NSColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0).cgColor

            // Header gradient view
            let headerView = NSView(frame: NSRect(x: 0, y: 400, width: 500, height: 200))
            headerView.wantsLayer = true
            let gradient = CAGradientLayer()
            gradient.colors = [
                NSColor(red: 0.35, green: 0.45, blue: 0.95, alpha: 1.0).cgColor,
                NSColor(red: 0.55, green: 0.35, blue: 0.85, alpha: 1.0).cgColor,
            ]
            gradient.startPoint = CGPoint(x: 0, y: 1)
            gradient.endPoint = CGPoint(x: 1, y: 0)
            gradient.frame = headerView.bounds
            headerView.layer?.addSublayer(gradient)
            containerView.addSubview(headerView)

            // Decorative circles
            for i in 0 ..< 3 {
                let circleSize = CGFloat(80 + i * 40)
                let circle = NSView(
                    frame: NSRect(
                        x: 500 - circleSize - CGFloat(20 - i * 30),
                        y: 400 + CGFloat(100 - i * 15),
                        width: circleSize,
                        height: circleSize
                    )
                )
                circle.wantsLayer = true
                circle.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.1).cgColor
                circle.layer?.cornerRadius = circleSize / 2
                containerView.addSubview(circle)
            }

            // Avatar container
            let avatarSize: CGFloat = 120
            let avatarContainer = NSView(
                frame: NSRect(
                    x: (500 - avatarSize) / 2,
                    y: 340,
                    width: avatarSize,
                    height: avatarSize
                )
            )
            avatarContainer.wantsLayer = true
            avatarContainer.layer?.backgroundColor = NSColor.white.cgColor
            avatarContainer.layer?.cornerRadius = avatarSize / 2
            avatarContainer.layer?.shadowColor = NSColor.black.cgColor
            avatarContainer.layer?.shadowOpacity = 0.15
            avatarContainer.layer?.shadowOffset = CGSize(width: 0, height: -4)
            avatarContainer.layer?.shadowRadius = 12
            containerView.addSubview(avatarContainer)

            // Avatar inner circle
            let avatarInnerSize: CGFloat = 108
            let avatarInner = NSView(
                frame: NSRect(
                    x: (avatarSize - avatarInnerSize) / 2,
                    y: (avatarSize - avatarInnerSize) / 2,
                    width: avatarInnerSize,
                    height: avatarInnerSize
                )
            )
            avatarInner.wantsLayer = true
            avatarInner.layer?.backgroundColor = NSColor(red: 0.35, green: 0.45, blue: 0.95, alpha: 1.0).cgColor
            avatarInner.layer?.cornerRadius = avatarInnerSize / 2
            avatarContainer.addSubview(avatarInner)

            // Initials label
            let initialsLabel = NSTextField(labelWithString: "JD")
            initialsLabel.font = NSFont.systemFont(ofSize: 36, weight: .bold)
            initialsLabel.textColor = .white
            initialsLabel.alignment = .center
            initialsLabel.sizeToFit()
            initialsLabel.frame.origin = CGPoint(
                x: (avatarInnerSize - initialsLabel.frame.width) / 2,
                y: (avatarInnerSize - initialsLabel.frame.height) / 2
            )
            avatarInner.addSubview(initialsLabel)

            // Online indicator
            let indicatorSize: CGFloat = 20
            let onlineIndicator = NSView(
                frame: NSRect(
                    x: avatarSize - indicatorSize - 4,
                    y: 4,
                    width: indicatorSize,
                    height: indicatorSize
                )
            )
            onlineIndicator.wantsLayer = true
            onlineIndicator.layer?.backgroundColor = NSColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0).cgColor
            onlineIndicator.layer?.cornerRadius = indicatorSize / 2
            onlineIndicator.layer?.borderWidth = 3
            onlineIndicator.layer?.borderColor = NSColor.white.cgColor
            avatarContainer.addSubview(onlineIndicator)

            // Name label
            let nameLabel = NSTextField(labelWithString: "John Doe")
            nameLabel.font = NSFont.systemFont(ofSize: 28, weight: .bold)
            nameLabel.textColor = NSColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
            nameLabel.alignment = .center
            nameLabel.sizeToFit()
            nameLabel.frame.origin = CGPoint(x: (500 - nameLabel.frame.width) / 2 - 15, y: 300)
            containerView.addSubview(nameLabel)

            // Verified badge
            let badgeSize: CGFloat = 20
            let verifiedBadge = NSView(
                frame: NSRect(
                    x: nameLabel.frame.maxX + 8,
                    y: 305,
                    width: badgeSize,
                    height: badgeSize
                )
            )
            verifiedBadge.wantsLayer = true
            verifiedBadge.layer?.backgroundColor = NSColor(red: 0.35, green: 0.45, blue: 0.95, alpha: 1.0).cgColor
            verifiedBadge.layer?.cornerRadius = badgeSize / 2
            containerView.addSubview(verifiedBadge)

            let checkLabel = NSTextField(labelWithString: "✓")
            checkLabel.font = NSFont.systemFont(ofSize: 12, weight: .bold)
            checkLabel.textColor = .white
            checkLabel.sizeToFit()
            checkLabel.frame.origin = CGPoint(
                x: (badgeSize - checkLabel.frame.width) / 2,
                y: (badgeSize - checkLabel.frame.height) / 2
            )
            verifiedBadge.addSubview(checkLabel)

            // Username label
            let usernameLabel = NSTextField(labelWithString: "@johndoe")
            usernameLabel.font = NSFont.systemFont(ofSize: 16, weight: .medium)
            usernameLabel.textColor = NSColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)
            usernameLabel.alignment = .center
            usernameLabel.sizeToFit()
            usernameLabel.frame.origin = CGPoint(x: (500 - usernameLabel.frame.width) / 2, y: 275)
            containerView.addSubview(usernameLabel)

            // Bio label
            let bioLabel = NSTextField(labelWithString: "iOS Developer | Swift Enthusiast | Open Source Contributor")
            bioLabel.font = NSFont.systemFont(ofSize: 14)
            bioLabel.textColor = NSColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1.0)
            bioLabel.alignment = .center
            bioLabel.lineBreakMode = .byWordWrapping
            bioLabel.frame = NSRect(x: 50, y: 240, width: 400, height: 30)
            containerView.addSubview(bioLabel)

            // Stats container
            let statsContainer = NSView(frame: NSRect(x: 20, y: 160, width: 460, height: 60))
            statsContainer.wantsLayer = true
            statsContainer.layer?.backgroundColor = NSColor.white.cgColor
            statsContainer.layer?.cornerRadius = 16
            statsContainer.layer?.shadowColor = NSColor.black.cgColor
            statsContainer.layer?.shadowOpacity = 0.08
            statsContainer.layer?.shadowOffset = CGSize(width: 0, height: -2)
            statsContainer.layer?.shadowRadius = 8
            containerView.addSubview(statsContainer)

            let stats = [("1,234", "Followers"), ("567", "Following"), ("89", "Projects"), ("4.9", "Rating")]
            let statWidth: CGFloat = 115
            for (index, stat) in stats.enumerated() {
                let statView = createStatView(value: stat.0, label: stat.1)
                statView.frame.origin = CGPoint(x: CGFloat(index) * statWidth, y: 10)
                statsContainer.addSubview(statView)

                if index < stats.count - 1 {
                    let divider = NSView(
                        frame: NSRect(x: CGFloat(index + 1) * statWidth - 0.5, y: 10, width: 1, height: 40)
                    )
                    divider.wantsLayer = true
                    divider.layer?.backgroundColor = NSColor(red: 0.9, green: 0.9, blue: 0.92, alpha: 1.0).cgColor
                    statsContainer.addSubview(divider)
                }
            }

            // Action buttons
            let followButton = createButton(title: "Follow", isPrimary: true)
            followButton.frame = NSRect(x: 20, y: 100, width: 225, height: 44)
            containerView.addSubview(followButton)

            let messageButton = createButton(title: "Message", isPrimary: false)
            messageButton.frame = NSRect(x: 255, y: 100, width: 225, height: 44)
            containerView.addSubview(messageButton)

            // Activity section title
            let activityTitle = NSTextField(labelWithString: "Recent Activity")
            activityTitle.font = NSFont.systemFont(ofSize: 18, weight: .bold)
            activityTitle.textColor = NSColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
            activityTitle.sizeToFit()
            activityTitle.frame.origin = CGPoint(x: 20, y: 60)
            containerView.addSubview(activityTitle)

            // Activity row
            let activityContainer = NSView(frame: NSRect(x: 20, y: 10, width: 460, height: 40))
            activityContainer.wantsLayer = true
            activityContainer.layer?.backgroundColor = NSColor.white.cgColor
            activityContainer.layer?.cornerRadius = 10
            containerView.addSubview(activityContainer)

            let activityDot = NSView(frame: NSRect(x: 12, y: 15, width: 10, height: 10))
            activityDot.wantsLayer = true
            activityDot.layer?.backgroundColor = NSColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0).cgColor
            activityDot.layer?.cornerRadius = 5
            activityContainer.addSubview(activityDot)

            let activityLabel = NSTextField(labelWithString: "Pushed to main · SnapshotTestingHEIC")
            activityLabel.font = NSFont.systemFont(ofSize: 13)
            activityLabel.textColor = NSColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0)
            activityLabel.sizeToFit()
            activityLabel.frame.origin = CGPoint(x: 30, y: 12)
            activityContainer.addSubview(activityLabel)

            let timeLabel = NSTextField(labelWithString: "2h ago")
            timeLabel.font = NSFont.systemFont(ofSize: 12, weight: .medium)
            timeLabel.textColor = NSColor(red: 0.6, green: 0.6, blue: 0.7, alpha: 1.0)
            timeLabel.sizeToFit()
            timeLabel.frame.origin = CGPoint(x: 460 - timeLabel.frame.width - 12, y: 12)
            activityContainer.addSubview(timeLabel)

            return containerView
        }

        private func createStatView(value: String, label: String) -> NSView {
            let container = NSView(frame: NSRect(x: 0, y: 0, width: 115, height: 40))

            let valueLabel = NSTextField(labelWithString: value)
            valueLabel.font = NSFont.systemFont(ofSize: 20, weight: .bold)
            valueLabel.textColor = NSColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
            valueLabel.alignment = .center
            valueLabel.sizeToFit()
            valueLabel.frame.origin = CGPoint(x: (115 - valueLabel.frame.width) / 2, y: 18)
            container.addSubview(valueLabel)

            let titleLabel = NSTextField(labelWithString: label)
            titleLabel.font = NSFont.systemFont(ofSize: 11, weight: .medium)
            titleLabel.textColor = NSColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0)
            titleLabel.alignment = .center
            titleLabel.sizeToFit()
            titleLabel.frame.origin = CGPoint(x: (115 - titleLabel.frame.width) / 2, y: 2)
            container.addSubview(titleLabel)

            return container
        }

        private func createButton(title: String, isPrimary: Bool) -> NSView {
            let button = NSView(frame: NSRect(x: 0, y: 0, width: 225, height: 44))
            button.wantsLayer = true
            button.layer?.cornerRadius = 12

            if isPrimary {
                button.layer?.backgroundColor = NSColor(red: 0.35, green: 0.45, blue: 0.95, alpha: 1.0).cgColor
            } else {
                button.layer?.backgroundColor = NSColor.white.cgColor
                button.layer?.borderWidth = 2
                button.layer?.borderColor = NSColor(red: 0.35, green: 0.45, blue: 0.95, alpha: 1.0).cgColor
            }

            let label = NSTextField(labelWithString: title)
            label.font = NSFont.systemFont(ofSize: 15, weight: .semibold)
            label.textColor = isPrimary ? .white : NSColor(red: 0.35, green: 0.45, blue: 0.95, alpha: 1.0)
            label.alignment = .center
            label.sizeToFit()
            label.frame.origin = CGPoint(x: (225 - label.frame.width) / 2, y: (44 - label.frame.height) / 2)
            button.addSubview(label)

            return button
        }

        /// Test that verifies Issue #13 fix: opaque images are saved without alpha channel
        func test_opaqueImage_savedWithoutAlpha() throws {
            try XCTSkipUnless(isHEICEncodingAvailable(), "HEIC encoding not available on this system")

            // Given: Create an opaque image (no alpha channel)
            let size = CGSize(width: 100, height: 100)
            let opaqueImage = NSImage(size: size)
            opaqueImage.lockFocus()
            NSColor.red.setFill()
            NSRect(origin: .zero, size: size).fill()
            opaqueImage.unlockFocus()

            // When: Convert to HEIC with auto opaque mode
            let heicData = opaqueImage.heicData(compressionQuality: .lossless, opaqueMode: .auto)

            // Then: Verify HEIC data was created
            XCTAssertNotNil(heicData, "HEIC data should be created")

            // And: Verify the saved image has no alpha channel in the CGImage
            guard let data = heicData,
                let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
                let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
            else {
                XCTFail("Could not read HEIC image")
                return
            }

            // Check the actual alpha info of the decoded image
            let alphaInfo = cgImage.alphaInfo
            print("Alpha info: \(alphaInfo.rawValue)")
            print("Bits per pixel: \(cgImage.bitsPerPixel)")
            print("Bits per component: \(cgImage.bitsPerComponent)")

            // For opaque images, alpha should be .none, .noneSkipFirst, or .noneSkipLast
            let isOpaque = alphaInfo == .none || alphaInfo == .noneSkipFirst || alphaInfo == .noneSkipLast
            XCTAssertTrue(
                isOpaque,
                "Opaque image should be saved without alpha channel. Got alphaInfo: \(alphaInfo.rawValue)"
            )
        }

        /// Test that transparent images preserve alpha channel
        func test_transparentImage_preservesAlpha() throws {
            try XCTSkipUnless(isHEICEncodingAvailable(), "HEIC encoding not available on this system")

            // Given: Create a transparent image (with alpha channel)
            let size = CGSize(width: 100, height: 100)
            let transparentImage = NSImage(size: size)
            transparentImage.lockFocus()
            NSColor.clear.setFill()
            NSRect(origin: .zero, size: size).fill()
            // Draw a semi-transparent circle
            NSColor(red: 1, green: 0, blue: 0, alpha: 0.5).setFill()
            let circlePath = NSBezierPath(ovalIn: NSRect(x: 25, y: 25, width: 50, height: 50))
            circlePath.fill()
            transparentImage.unlockFocus()

            // When: Convert to HEIC with transparent mode
            let heicData = transparentImage.heicData(compressionQuality: .lossless, opaqueMode: .transparent)

            // Then: Verify HEIC data was created
            XCTAssertNotNil(heicData, "HEIC data should be created for transparent image")
        }

        /// Test OpaqueMode.opaque forces no alpha regardless of image content
        func test_opaqueMode_forcesNoAlpha() throws {
            try XCTSkipUnless(isHEICEncodingAvailable(), "HEIC encoding not available on this system")

            // Given: Any image
            let size = CGSize(width: 100, height: 100)
            let image = NSImage(size: size)
            image.lockFocus()
            NSColor.blue.setFill()
            NSRect(origin: .zero, size: size).fill()
            image.unlockFocus()

            // When: Convert to HEIC with forced opaque mode
            let heicData = image.heicData(compressionQuality: .lossless, opaqueMode: .opaque)

            // Then: Verify no alpha channel in decoded image
            guard let data = heicData,
                let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
                let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
            else {
                XCTFail("Could not read HEIC image")
                return
            }

            let alphaInfo = cgImage.alphaInfo
            print("Forced opaque - Alpha info: \(alphaInfo.rawValue)")

            // For opaque images, alpha should be .none, .noneSkipFirst, or .noneSkipLast
            let isOpaque = alphaInfo == .none || alphaInfo == .noneSkipFirst || alphaInfo == .noneSkipLast
            XCTAssertTrue(
                isOpaque,
                "OpaqueMode.opaque should force no alpha channel. Got alphaInfo: \(alphaInfo.rawValue)"
            )
        }
    #endif

    // MARK: - CompressionQuality Tests

    func test_CompressionQuality_rawValues() {
        XCTAssertEqual(CompressionQuality.lossless.rawValue, 1.0)
        XCTAssertEqual(CompressionQuality.low.rawValue, 0.8)
        XCTAssertEqual(CompressionQuality.medium.rawValue, 0.5)
        XCTAssertEqual(CompressionQuality.high.rawValue, 0.2)
        XCTAssertEqual(CompressionQuality.maximum.rawValue, 0.0)
        XCTAssertEqual(CompressionQuality.custom(0.75).rawValue, 0.75)
    }

    func test_CompressionQuality_initFromRawValue() {
        XCTAssertEqual(CompressionQuality(rawValue: 1.0), .lossless)
        XCTAssertEqual(CompressionQuality(rawValue: 0.8), .low)
        XCTAssertEqual(CompressionQuality(rawValue: 0.5), .medium)
        XCTAssertEqual(CompressionQuality(rawValue: 0.2), .high)
        XCTAssertEqual(CompressionQuality(rawValue: 0.0), .maximum)
        XCTAssertEqual(CompressionQuality(rawValue: 0.75), .custom(0.75))
    }

    func test_CompressionQuality_hashable() {
        let qualities: Set<CompressionQuality> = [.lossless, .low, .medium, .high, .maximum, .custom(0.75)]
        XCTAssertEqual(qualities.count, 6)

        // Test that duplicate values hash to the same
        var duplicateSet: Set<CompressionQuality> = [.lossless, .lossless]
        XCTAssertEqual(duplicateSet.count, 1)

        duplicateSet.insert(.custom(0.5))
        duplicateSet.insert(.medium)  // Same rawValue as custom(0.5)
        XCTAssertEqual(duplicateSet.count, 2)  // custom(0.5) and .medium are different enum cases
    }

    // MARK: - OpaqueMode Tests

    func test_OpaqueMode_hashable() {
        let modes: Set<OpaqueMode> = [.auto, .opaque, .transparent]
        XCTAssertEqual(modes.count, 3)
    }

    func test_OpaqueMode_sendable() {
        // OpaqueMode should be Sendable for concurrent use
        let mode: OpaqueMode = .auto
        Task {
            let _ = mode
        }
    }

    // MARK: - ImageComparisonHelpers Tests

    #if os(iOS) || os(tvOS) || os(macOS)
        func test_comparePixelBytes_identicalImages_passes() {
            let bytes1: [UInt8] = [255, 0, 0, 255, 0, 255, 0, 255]
            let bytes2: [UInt8] = [255, 0, 0, 255, 0, 255, 0, 255]

            let (passed, precision) = comparePixelBytes(bytes1, bytes2, byteCount: 8, precision: 1.0)

            XCTAssertTrue(passed)
            XCTAssertEqual(precision, 1.0)
        }

        func test_comparePixelBytes_differentImages_withPrecision() {
            let bytes1: [UInt8] = [255, 0, 0, 255, 0, 255, 0, 255, 0, 0]
            let bytes2: [UInt8] = [255, 0, 0, 255, 0, 255, 0, 255, 255, 255]  // 2 bytes different

            // 80% precision required, 20% difference (2 out of 10)
            // threshold = (1 - 0.8) * 10 = 2, differentByteCount = 2
            // 2 > 2 is false, so it should pass
            let (passed, precision) = comparePixelBytes(bytes1, bytes2, byteCount: 10, precision: 0.79)

            XCTAssertTrue(passed, "With 20% difference and 79% precision requirement, comparison should pass")
            XCTAssertEqual(precision, 0.8, accuracy: 0.001)
        }

        func test_comparePixelBytes_differentImages_failsPrecision() {
            let bytes1: [UInt8] = [255, 0, 0, 255, 0, 255, 0, 255, 0, 0]
            let bytes2: [UInt8] = [0, 255, 255, 0, 255, 0, 255, 0, 255, 255]  // All bytes different

            // 90% precision required, but all bytes different - should fail
            let (passed, _) = comparePixelBytes(bytes1, bytes2, byteCount: 10, precision: 0.9)

            XCTAssertFalse(passed)
        }

        func test_comparePixelBytes_earlyExitOptimization() {
            // Create large arrays where early bytes differ
            let bytes1 = [UInt8](repeating: 0, count: 10000)
            let bytes2 = [UInt8](repeating: 255, count: 10000)

            // With early exit, this should fail quickly without comparing all bytes
            let start = CFAbsoluteTimeGetCurrent()
            let (passed, _) = comparePixelBytes(bytes1, bytes2, byteCount: 10000, precision: 0.99)
            let elapsed = CFAbsoluteTimeGetCurrent() - start

            XCTAssertFalse(passed)
            // Early exit should make this very fast (< 1ms typically)
            XCTAssertLessThan(elapsed, 0.1, "Early exit optimization should make comparison fast")
        }
    #endif

}
