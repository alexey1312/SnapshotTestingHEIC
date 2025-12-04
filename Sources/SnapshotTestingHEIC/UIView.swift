#if os(iOS) || os(tvOS)
    import UIKit
    @testable import SnapshotTesting

    public extension Snapshotting where Value == UIView, Format == UIImage {
        /// A snapshot strategy for comparing views based on pixel equality.
        static var imageHEIC: Snapshotting {
            return .imageHEIC()
        }

        /// A snapshot strategy for comparing views based on pixel equality.
        ///
        /// - Parameters:
        ///   - drawHierarchyInKeyWindow: Utilize the simulator's key window in order to render
        ///   `UIAppearance` and `UIVisualEffect`s. This option requires a host application for your tests and
        ///   will _not_ work for framework test targets.
        ///   - precision: The percentage of pixels that must match.
        ///   - perceptualPrecision: The percentage a pixel must match the source pixel to be considered a match. [98-99% mimics the precision of the human eye.](http://zschuessler.github.io/DeltaE/learn/#toc-defining-delta-e)
        ///   - size: A view size override.
        ///   - traits: A trait collection override.
        ///   - compressionQuality: The desired compression quality to use when writing to an image destination.
        ///   - opaqueMode: Controls alpha channel handling. Use `.auto` to automatically detect, `.opaque` to force no alpha, or `.transparent` to force alpha channel.
        static func imageHEIC(
            drawHierarchyInKeyWindow: Bool = false,
            precision: Float = 1,
            perceptualPrecision: Float = 1,
            size: CGSize? = nil,
            traits: UITraitCollection = .init(),
            compressionQuality: CompressionQuality = .lossless,
            opaqueMode: OpaqueMode = .auto
        )
            -> Snapshotting
        {
            return SimplySnapshotting.imageHEIC(
                precision: precision,
                perceptualPrecision: perceptualPrecision,
                scale: traits.displayScale,
                compressionQuality: compressionQuality,
                opaqueMode: opaqueMode
            ).asyncPullback { view in
                snapshotView(
                    config: .init(safeArea: .zero, size: size ?? view.frame.size, traits: .init()),
                    drawHierarchyInKeyWindow: drawHierarchyInKeyWindow,
                    traits: traits,
                    view: view,
                    viewController: .init()
                )
            }
        }
    }
#endif
