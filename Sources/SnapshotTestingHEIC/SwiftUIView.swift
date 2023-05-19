//
//  SwiftUIView.swift
//
//  Created by Emanuel Cunha on 20/05/2023
//

#if canImport(SwiftUI)
import Foundation
import SwiftUI
@testable import SnapshotTesting

#if os(iOS) || os(tvOS)
@available(iOS 13.0, tvOS 13.0, *)
public extension Snapshotting where Value: SwiftUI.View, Format == UIImage {

    /// A snapshot strategy for comparing views based on pixel equality.
    static var imageHEIC: Snapshotting {
        return .imageHEIC()
    }

    /// A snapshot strategy for comparing SwiftUI Views based on pixel equality.
    ///
    /// - Parameters:
    ///   - drawHierarchyInKeyWindow: Utilize the simulator's key window in order to render `UIAppearance` and `UIVisualEffect`s. This option requires a host application for your tests and will _not_ work for framework test targets.
    ///   - precision: The percentage of pixels that must match.
    ///   - perceptualPrecision: The percentage a pixel must match the source pixel to be considered a match. [98-99% mimics the precision of the human eye.](http://zschuessler.github.io/DeltaE/learn/#toc-defining-delta-e)
    ///   - layout: A view layout override.
    ///   - traits: A trait collection override.
    ///   - compressionQuality: The desired compression quality to use when writing to an image destination.
    static func imageHEIC(
        drawHierarchyInKeyWindow: Bool = false,
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        layout: SwiftUISnapshotLayout = .sizeThatFits,
        traits: UITraitCollection = .init(),
        compressionQuality: CompressionQuality = .lossless
    ) -> Snapshotting {
        let config: ViewImageConfig

        switch layout {
#if os(iOS) || os(tvOS)
        case let .device(config: deviceConfig):
            config = deviceConfig
#endif
        case .sizeThatFits:
            config = .init(safeArea: .zero, size: nil, traits: traits)
        case let .fixed(width: width, height: height):
            let size = CGSize(width: width, height: height)
            config = .init(safeArea: .zero, size: size, traits: traits)
        }

        return SimplySnapshotting.imageHEIC(
            precision: precision,
            perceptualPrecision: perceptualPrecision,
            scale: traits.displayScale,
            compressionQuality: compressionQuality
        ).asyncPullback { view in
            var config = config

            let controller: UIViewController

            if config.size != nil {
                controller = UIHostingController.init(
                    rootView: view
                )
            } else {
                let hostingController = UIHostingController.init(rootView: view)

                let maxSize = CGSize(width: 0.0, height: 0.0)
                config.size = hostingController.sizeThatFits(in: maxSize)

                controller = hostingController
            }

            return snapshotView(
                config: config.size.map { .init(safeArea: config.safeArea, size: $0, traits: config.traits) } ?? config,
                drawHierarchyInKeyWindow: false,
                traits: traits,
                view: controller.view,
                viewController: controller
            )
        }
    }
}
#endif
#endif
