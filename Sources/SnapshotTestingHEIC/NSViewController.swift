#if os(macOS)
import Cocoa
@testable import SnapshotTesting

public extension Snapshotting where Value == NSViewController, Format == NSImage {
    /// A snapshot strategy for comparing view controller views based on pixel equality.
    static var imageHEIC: Snapshotting {
        return .imageHEIC()
    }

    /// A snapshot strategy for comparing view controller views based on pixel equality.
    ///
    /// - Parameters:
    ///   - precision: The percentage of pixels that must match.
    ///   - size: A view size override.
    static func imageHEIC(precision: Float = 1, size: CGSize? = nil) -> Snapshotting {
        return Snapshotting<NSView, NSImage>.imageHEIC(precision: precision, size: size).pullback { $0.view }
    }
}
#endif
