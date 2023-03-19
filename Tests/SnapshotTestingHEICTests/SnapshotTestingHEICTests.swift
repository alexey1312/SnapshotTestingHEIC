// Use iPhone 8 for tests
import XCTest
import SnapshotTesting
@testable import SnapshotTestingHEIC

final class SnapshotTestingHEICTests: XCTestCase {

#if os(iOS) || os(tvOS)
    var sut: TestViewController!

    override func setUp() {
        super.setUp()
        sut = TestViewController()
//        isRecording = true
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_without_HEIC() {
        assertSnapshot(matching: sut, as: .image(on: .iPadPro12_9))
    }

    func test_HEIC_compressionQuality_lossless() {
        assertSnapshot(matching: sut, as: .imageHEIC(on: .iPadPro12_9,
                                                     compressionQuality: .lossless))
    }

    func test_HEIC_compressionQuality_medium() {
        assertSnapshot(matching: sut, as: .imageHEIC(on: .iPadPro12_9,
                                                     compressionQuality: .medium))
    }

    func test_HEIC_compressionQuality_maximum() {
        assertSnapshot(matching: sut, as: .imageHEIC(on: .iPadPro12_9,
                                                     compressionQuality: .maximum))
    }

    func test_HEIC_compressionQuality_custom() {
        assertSnapshot(matching: sut, as: .imageHEIC(on: .iPadPro12_9,
                                                     compressionQuality: 0.75))
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
        assertSnapshot(matching: view, as: .imageHEIC)
    }
#endif

}
