#if os(macOS)
import Cocoa
@testable import SnapshotTesting

public extension Snapshotting where Value == NSView, Format == NSImage {
    /// A snapshot strategy for comparing views based on pixel equality.
    static var imageHEIC: Snapshotting {
        return .imageHEIC()
    }

    /// A snapshot strategy for comparing views based on pixel equality.
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
        return SimplySnapshotting.imageHEIC(
            precision: precision,
            compressionQuality: compressionQuality,
            opaqueMode: opaqueMode
        ).asyncPullback { view in
            let initialSize = view.frame.size
            if let size = size { view.frame.size = size }
            guard view.frame.width > 0, view.frame.height > 0 else {
                fatalError("View not renderable to image at size \(view.frame.size)")
            }
            return view.snapshot ?? Async { callback in
                addImagesForRenderedViews(view).sequence().run { views in
                    let bitmapRep = view.bitmapImageRepForCachingDisplay(in: view.bounds)!
                    view.cacheDisplay(in: view.bounds, to: bitmapRep)
                    let image = NSImage(size: view.bounds.size)
                    image.addRepresentation(bitmapRep)
                    callback(image)
                    views.forEach { $0.removeFromSuperview() }
                    view.frame.size = initialSize
                }
            }
        }
    }
}
#endif
