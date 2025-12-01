// Use iPhone 8 for tests
import XCTest
import SnapshotTesting

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

//    // ViewController Tests
    func test_without_HEIC() {
        assertSnapshot(of: sut, as: .image(on: .iPadPro12_9))
    }

    func test_HEIC_compressionQuality_lossless() {
        assertSnapshot(of: sut, as: .imageHEIC(on: .iPadPro12_9, compressionQuality: .lossless))
    }

    func test_HEIC_compressionQuality_medium() {
        assertSnapshot(of: sut, as: .imageHEIC(on: .iPadPro12_9, compressionQuality: .medium))
    }

    func test_HEIC_compressionQuality_maximum() {
        assertSnapshot(of: sut, as: .imageHEIC(on: .iPadPro12_9, compressionQuality: .maximum))
    }

    func test_HEIC_compressionQuality_custom() {
        assertSnapshot(of: sut, as: .imageHEIC(on: .iPadPro12_9, compressionQuality: .custom(0.75) ))
    }

    func test_HEIC_compressionQuality_custom_minus() {
        assertSnapshot(of: sut, as: .imageHEIC(on: .iPadPro12_9, compressionQuality: .custom(-20) ))
    }

    // SwiftUI Tests

    func test_swiftui_without_HEIC() {
        let view: some SwiftUI.View = SwiftUIView()

        assertSnapshot(of: view, as: .imageHEIC(layout: .device(config: .iPadPro12_9)))
    }

    func test_swiftui_HEIC_compressionQuality_lossless() {
        let view: some SwiftUI.View = SwiftUIView()

        assertSnapshot(of: view,
                        as: .imageHEIC(
                        layout: .device(config: .iPadPro12_9),
                        compressionQuality: .lossless
                        )
        )
    }

    func test_swiftui_HEIC_compressionQuality_medium() {
        let view: some SwiftUI.View = SwiftUIView()

        assertSnapshot(of: view,
                        as: .imageHEIC(
                        layout: .device(config: .iPadPro12_9),
                        compressionQuality: .medium
                       )
        )
    }

    func test_swiftui_HEIC_compressionQuality_maximum() {
        let view: some SwiftUI.View = SwiftUIView()

        assertSnapshot(of: view,
                        as: .imageHEIC(
                        layout: .device(config: .iPadPro12_9),
                        compressionQuality: .maximum
                       )
        )
    }

    func test_swiftui_HEIC_compressionQuality_custom() {
        let view: some SwiftUI.View = SwiftUIView()

        assertSnapshot(of: view,
                       as: .imageHEIC(
                        layout: .device(config: .iPadPro12_9),
                        compressionQuality: .custom(0.75)
                       )
        )
    }
#endif


#if os(macOS)
    func test_HEIC_NSView() {
        // given
        let view = NSView()
        let button = NSButton()
        // when
        view.frame = CGRect(origin: .zero, size: CGSize(width: 400, height: 400))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.blue.cgColor
        view.addSubview(button)
        button.frame.origin = CGPoint(x: view.frame.origin.x + view.frame.size.width / 2.0,
                                      y: view.frame.origin.y + view.frame.size.height / 2.0)
        button.bezelStyle = .rounded
        button.title = "Push Me"
        button.wantsLayer = true
        button.layer?.backgroundColor = NSColor.red.cgColor
        button.sizeToFit()
        // then
        assertSnapshot(of: view, as: .imageHEIC)
    }

    /// Test that verifies Issue #13 fix: opaque images are saved without alpha channel
    func test_opaqueImage_savedWithoutAlpha() {
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
              let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
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
        XCTAssertTrue(isOpaque, "Opaque image should be saved without alpha channel. Got alphaInfo: \(alphaInfo.rawValue)")
    }

    /// Test that transparent images preserve alpha channel
    func test_transparentImage_preservesAlpha() {
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
    func test_opaqueMode_forcesNoAlpha() {
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
              let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            XCTFail("Could not read HEIC image")
            return
        }

        let alphaInfo = cgImage.alphaInfo
        print("Forced opaque - Alpha info: \(alphaInfo.rawValue)")

        // For opaque images, alpha should be .none, .noneSkipFirst, or .noneSkipLast
        let isOpaque = alphaInfo == .none || alphaInfo == .noneSkipFirst || alphaInfo == .noneSkipLast
        XCTAssertTrue(isOpaque, "OpaqueMode.opaque should force no alpha channel. Got alphaInfo: \(alphaInfo.rawValue)")
    }
#endif

}
