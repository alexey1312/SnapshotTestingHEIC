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
    ///   - compressionQuality: The desired compression quality to use when writing to an image destination.
    ///   - opaqueMode: Controls alpha channel handling. Use `.auto` to automatically detect, `.opaque` to force no alpha, or `.transparent` to force alpha channel.
    static func imageHEIC(
        precision: Float = 1,
        size: CGSize? = nil,
        compressionQuality: CompressionQuality = .lossless,
        opaqueMode: OpaqueMode = .auto
    ) -> Snapshotting {
        return Snapshotting<NSView, NSImage>.imageHEIC(
            precision: precision,
            size: size,
            compressionQuality: compressionQuality,
            opaqueMode: opaqueMode
        ).pullback { $0.view }
    }
}
#endif
