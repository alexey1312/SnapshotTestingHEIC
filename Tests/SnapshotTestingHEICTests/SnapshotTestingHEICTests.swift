#if os(iOS) || os(tvOS)
import XCTest
import SnapshotTesting
@testable import SnapshotTestingHEIC

final class SnapshotTestingHEICTests: XCTestCase {

    var sut: TestViewController!

    override func setUp() {
        super.setUp()
        sut = TestViewController()
//        isRecording = true
    }

    override func tearDown() {
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

}
#endif
