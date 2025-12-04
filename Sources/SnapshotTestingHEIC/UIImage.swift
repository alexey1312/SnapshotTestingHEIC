#if os(iOS) || os(tvOS)
    import UIKit
    import XCTest
    import SnapshotTesting

    public extension Diffing where Value == UIImage {
        /// A pixel-diffing strategy for UIImage's which requires a 100% match.
        static let imageHEIC = Diffing.imageHEIC()

        /// A pixel-diffing strategy for UIImage that allows customizing how precise the matching must be.
        ///
        /// - Parameter precision: A value between 0 and 1, where 1 means the images must match 100% of their pixels.
        /// - Parameter perceptualPrecision: The percentage a pixel must match the source pixel to be considered a match. [98-99% mimics the precision of the human eye.](http://zschuessler.github.io/DeltaE/learn/#toc-defining-delta-e)
        /// - Parameter scale: Scale to use when loading the reference image from disk. If `nil` or the `UITraitCollection`s
        /// default value of `0.0`, the screens scale is used.
        /// - Parameter compressionQuality: The desired compression quality to use when writing to an image destination.
        /// - Parameter opaqueMode: Controls alpha channel handling. Use `.auto` to automatically detect, `.opaque` to force no alpha, or `.transparent` to force alpha channel.
        /// - Returns: A new diffing strategy.
        static func imageHEIC(
            precision: Float = 1,
            perceptualPrecision: Float = 1,
            scale: CGFloat? = nil,
            compressionQuality: CompressionQuality = .lossless,
            opaqueMode: OpaqueMode = .auto
        ) -> Diffing {
            let imageScale: CGFloat
            if let scale = scale, scale != 0.0 {
                imageScale = scale
            } else {
                imageScale = UIScreen.main.scale
            }

            let emptyHeicData: Data
            if #available(iOS 17.0, tvOS 17.0, *) {
                emptyHeicData = emptyImage().heicData(compressionQuality: .lossless, opaqueMode: opaqueMode) ?? Data()
            } else {
                emptyHeicData = Data()
            }
            return Diffing(
                toData: {
                    $0.heicData(compressionQuality: compressionQuality, opaqueMode: opaqueMode) ?? emptyHeicData
                },
                fromData: { UIImage(data: $0, scale: imageScale) ?? emptyImage() },
                diff: { old, new in
                    guard
                        let message = compare(
                            old,
                            new,
                            precision: precision,
                            perceptualPrecision: perceptualPrecision,
                            compressionQuality: compressionQuality,
                            opaqueMode: opaqueMode
                        )
                    else { return nil }

                    let difference = diffImage(old, new)

                    // Note: XCTest may still produce "opaque image with AlphaLast" warnings
                    // when saving attachments to xcresult. This is internal XCTest behavior
                    // and cannot be suppressed. The warning is informational only.
                    let oldAttachment = XCTAttachment(image: old)
                    oldAttachment.name = "reference"
                    oldAttachment.lifetime = .keepAlways

                    let isEmptyImage = new.size == .zero
                    let newAttachment = XCTAttachment(image: isEmptyImage ? emptyImage() : new)
                    newAttachment.name = "failure"
                    newAttachment.lifetime = .keepAlways

                    let differenceAttachment = XCTAttachment(image: difference)
                    differenceAttachment.name = "difference"
                    differenceAttachment.lifetime = .keepAlways

                    return (
                        message,
                        [oldAttachment, newAttachment, differenceAttachment]
                    )
                }
            )
        }

        /// Used when the image size has no width or no height to generated the default empty image
        private static func emptyImage() -> UIImage {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 80))
            label.backgroundColor = .red
            label.text = """
                Error: No image could be generated for this view as its size was zero.
                Please set an explicit size in the test.
                """
            label.textAlignment = .center
            label.numberOfLines = 3
            return label.asImage()
        }
    }

    public extension Snapshotting where Value == UIImage, Format == UIImage {
        /// A snapshot strategy for comparing images based on pixel equality.
        static var imageHEIC: Snapshotting {
            return .imageHEIC()
        }

        /// A snapshot strategy for comparing images based on pixel equality.
        ///
        /// - Parameter precision: The percentage of pixels that must match.
        /// - Parameter perceptualPrecision: The percentage a pixel must match the source pixel to be considered a match. [98-99% mimics the precision of the human eye.](http://zschuessler.github.io/DeltaE/learn/#toc-defining-delta-e)
        /// - Parameter scale: The scale of the reference image stored on disk.
        /// - Parameter compressionQuality: The desired compression quality to use when writing to an image destination.
        /// - Parameter opaqueMode: Controls alpha channel handling. Use `.auto` to automatically detect, `.opaque` to force no alpha, or `.transparent` to force alpha channel.
        static func imageHEIC(
            precision: Float = 1,
            perceptualPrecision: Float = 1,
            scale: CGFloat? = nil,
            compressionQuality: CompressionQuality = .lossless,
            opaqueMode: OpaqueMode = .auto
        ) -> Snapshotting {
            return Snapshotting(
                pathExtension: "heic",
                diffing: Diffing<UIImage>
                    .imageHEIC(
                        precision: precision,
                        perceptualPrecision: perceptualPrecision,
                        scale: scale,
                        compressionQuality: compressionQuality,
                        opaqueMode: opaqueMode
                    )
            )
        }
    }

    private func compare(
        _ old: UIImage,
        _ new: UIImage,
        precision: Float,
        perceptualPrecision: Float,
        compressionQuality: CompressionQuality,
        opaqueMode: OpaqueMode = .auto
    ) -> String? {
        guard let oldCgImage = old.cgImage else {
            return "Reference image could not be loaded."
        }
        guard let newCgImage = new.cgImage else {
            return "Newly-taken snapshot could not be loaded."
        }
        guard newCgImage.width != 0, newCgImage.height != 0 else {
            return "Newly-taken snapshot is empty."
        }
        guard oldCgImage.width == newCgImage.width, oldCgImage.height == newCgImage.height else {
            return "Newly-taken snapshot@\(new.size) does not match reference@\(old.size)."
        }

        let pixelCount = oldCgImage.width * oldCgImage.height
        let byteCount = imageContextBytesPerPixel * pixelCount

        // Allocate single reusable buffer to reduce memory pressure
        var pixelBuffer = [UInt8](repeating: 0, count: byteCount)

        guard let oldContext = createImageContext(for: oldCgImage, data: &pixelBuffer),
            let oldData = oldContext.data
        else {
            return "Reference image's data could not be loaded."
        }

        // Copy old bytes since we'll reuse the buffer
        let oldBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: byteCount)
        defer { oldBytes.deallocate() }
        memcpy(oldBytes, oldData, byteCount)

        // Fast path: compare raw new image first (before HEIC encoding)
        if let newContext = createImageContext(for: newCgImage, data: &pixelBuffer),
            let newData = newContext.data
        {
            if memcmp(oldBytes, newData, byteCount) == 0 { return nil }
        }

        // HEIC round-trip comparison (simulates save/load cycle)
        guard
            let heicData = new.heicData(compressionQuality: compressionQuality, opaqueMode: opaqueMode),
            let newerCgImage = UIImage(data: heicData)?.cgImage,
            let newerContext = createImageContext(for: newerCgImage, data: &pixelBuffer),
            let newerData = newerContext.data
        else {
            return "Newly-taken snapshot's data could not be loaded."
        }

        // Fast path: exact match after HEIC round-trip
        if memcmp(oldBytes, newerData, byteCount) == 0 { return nil }

        // No match with full precision required
        if precision >= 1, perceptualPrecision >= 1 {
            return "Newly-taken snapshot does not match reference."
        }

        // Perceptual comparison using GPU (Delta E color difference)
        if perceptualPrecision < 1, #available(iOS 11.0, tvOS 11.0, *) {
            return perceptuallyCompare(
                CIImage(cgImage: oldCgImage),
                CIImage(cgImage: newCgImage),
                pixelPrecision: precision,
                perceptualPrecision: perceptualPrecision
            )
        }

        // Precision-based pixel comparison with optimized block comparison
        let (passed, actualPrecision) = comparePixelBytes(
            oldBytes,
            newerData.assumingMemoryBound(to: UInt8.self),
            byteCount: byteCount,
            precision: precision
        )
        if !passed {
            return "Actual image precision \(actualPrecision) is less than required \(precision)"
        }
        return nil
    }

    private func diffImage(_ old: UIImage, _ new: UIImage) -> UIImage {
        let width = max(old.size.width, new.size.width)
        let height = max(old.size.height, new.size.height)
        let scale = max(old.scale, new.scale)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), true, scale)
        new.draw(at: .zero)
        old.draw(at: .zero, blendMode: .difference, alpha: 1)
        let differenceImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return differenceImage
    }
#endif

#if os(iOS) || os(tvOS) || os(macOS)
    import CoreImage.CIKernel
    import MetalPerformanceShaders

    @available(iOS 10.0, tvOS 10.0, macOS 10.13, *)
    func perceptuallyCompare(_ old: CIImage, _ new: CIImage, pixelPrecision: Float, perceptualPrecision: Float)
        -> String?
    {
        let deltaOutputImage = old.applyingFilter("CILabDeltaE", parameters: ["inputImage2": new])
        let thresholdOutputImage: CIImage
        do {
            thresholdOutputImage = try ThresholdImageProcessorKernel.apply(
                withExtent: new.extent,
                inputs: [deltaOutputImage],
                arguments: [ThresholdImageProcessorKernel.inputThresholdKey: (1 - perceptualPrecision) * 100]
            )
        } catch {
            return "Newly-taken snapshot's data could not be loaded. \(error)"
        }
        var averagePixel: Float = 0
        let context = CIContext(options: [.workingColorSpace: NSNull(), .outputColorSpace: NSNull()])
        context.render(
            thresholdOutputImage.applyingFilter("CIAreaAverage", parameters: [kCIInputExtentKey: new.extent]),
            toBitmap: &averagePixel,
            rowBytes: MemoryLayout<Float>.size,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .Rf,
            colorSpace: nil
        )
        let actualPixelPrecision = 1 - averagePixel
        guard actualPixelPrecision < pixelPrecision else { return nil }
        var maximumDeltaE: Float = 0
        context.render(
            deltaOutputImage.applyingFilter("CIAreaMaximum", parameters: [kCIInputExtentKey: new.extent]),
            toBitmap: &maximumDeltaE,
            rowBytes: MemoryLayout<Float>.size,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .Rf,
            colorSpace: nil
        )
        let actualPerceptualPrecision = 1 - maximumDeltaE / 100
        if pixelPrecision < 1 {
            return """
                Actual image precision \(actualPixelPrecision) is less than required \(pixelPrecision)
                Actual perceptual precision \(actualPerceptualPrecision) is less than required \(perceptualPrecision)
                """
        } else {
            return
                "Actual perceptual precision \(actualPerceptualPrecision) is less than required \(perceptualPrecision)"
        }
    }

    // Copied from https://developer.apple.com/documentation/coreimage/ciimageprocessorkernel
    @available(iOS 10.0, tvOS 10.0, macOS 10.13, *)
    final class ThresholdImageProcessorKernel: CIImageProcessorKernel {
        static let inputThresholdKey = "thresholdValue"
        static let device = MTLCreateSystemDefaultDevice()

        override class func process(
            with inputs: [CIImageProcessorInput]?,
            arguments: [String: Any]?,
            output: CIImageProcessorOutput
        ) throws {
            guard
                let device = device,
                let commandBuffer = output.metalCommandBuffer,
                let input = inputs?.first,
                let sourceTexture = input.metalTexture,
                let destinationTexture = output.metalTexture,
                let thresholdValue = arguments?[inputThresholdKey] as? Float
            else {
                return
            }

            let threshold = MPSImageThresholdBinary(
                device: device,
                thresholdValue: thresholdValue,
                maximumValue: 1.0,
                linearGrayColorTransform: nil
            )

            threshold.encode(
                commandBuffer: commandBuffer,
                sourceTexture: sourceTexture,
                destinationTexture: destinationTexture
            )
        }
    }
#endif

#if os(macOS)
    import AppKit
    typealias Image = NSImage
    typealias View = NSView
#elseif os(iOS) || os(tvOS)
    typealias Image = UIImage
    typealias View = UIView
#endif

#if os(iOS) || os(tvOS)
    extension View {
        func asImage() -> Image {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        }
    }
#endif
