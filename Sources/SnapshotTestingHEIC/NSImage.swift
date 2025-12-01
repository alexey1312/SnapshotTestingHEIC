#if os(macOS)
import Cocoa
import XCTest
@testable import SnapshotTesting

public extension Diffing where Value == NSImage {
    /// A pixel-diffing strategy for NSImage's which requires a 100% match.
    static let imageHEIC = Diffing.imageHEIC(precision: 1, compressionQuality: .lossless)

    /// A pixel-diffing strategy for NSImage that allows customizing how precise the matching must be.
    ///
    /// - Parameter precision: A value between 0 and 1, where 1 means the images must match 100% of their pixels.
    /// - Parameter compressionQuality: The desired compression quality to use when writing to an image destination.
    /// - Parameter opaqueMode: Controls alpha channel handling. Use `.auto` to automatically detect, `.opaque` to force no alpha, or `.transparent` to force alpha channel.
    /// - Returns: A new diffing strategy.
    static func imageHEIC(
        precision: Float,
        compressionQuality: CompressionQuality = .lossless,
        opaqueMode: OpaqueMode = .auto
    ) -> Diffing {
        let emptyHeicData = emptyImage().heicData(compressionQuality: .lossless, opaqueMode: opaqueMode) ?? Data()
        return .init(
            toData: { $0.heicData(compressionQuality: compressionQuality, opaqueMode: opaqueMode) ?? emptyHeicData },
            fromData: { NSImage(data: $0) ?? emptyImage() }
        ) { old, new in
            guard let message = compare(old, new, precision: precision, compressionQuality: compressionQuality, opaqueMode: opaqueMode)
            else { return nil }
            let difference = diffNSImage(old, new)

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
    }

    /// Used when the image size has no width or no height to generated the default empty image
    private static func emptyImage() -> NSImage {
        let size = NSSize(width: 400, height: 80)
        let image = NSImage(size: size)
        image.lockFocus()

        NSColor.red.setFill()
        NSRect(origin: .zero, size: size).fill()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white,
            .font: NSFont.systemFont(ofSize: 12),
            .paragraphStyle: paragraphStyle
        ]

        let text = """
            Error: No image could be generated for this view as its size was zero.
            Please set an explicit size in the test.
            """
        let textRect = NSRect(x: 0, y: 20, width: 400, height: 60)
        text.draw(in: textRect, withAttributes: attributes)

        image.unlockFocus()
        return image
    }
}

public extension Snapshotting where Value == NSImage, Format == NSImage {
    /// A snapshot strategy for comparing images based on pixel equality.
    static var imageHEIC: Snapshotting {
        return .imageHEIC(precision: 1)
    }

    /// A snapshot strategy for comparing images based on pixel equality.
    ///
    /// - Parameter precision: The percentage of pixels that must match.
    /// - Parameter compressionQuality: The desired compression quality to use when writing to an image destination.
    /// - Parameter opaqueMode: Controls alpha channel handling. Use `.auto` to automatically detect, `.opaque` to force no alpha, or `.transparent` to force alpha channel.
    static func imageHEIC(
        precision: Float,
        compressionQuality: CompressionQuality = .lossless,
        opaqueMode: OpaqueMode = .auto
    ) -> Snapshotting {
        return .init(
            pathExtension: "heic",
            diffing: .imageHEIC(precision: precision, compressionQuality: compressionQuality, opaqueMode: opaqueMode)
        )
    }
}

private func NSImageHEICRepresentation(
    _ image: NSImage,
    compressionQuality: CompressionQuality,
    opaqueMode: OpaqueMode = .auto
) -> Data? {
    return image.heicData(compressionQuality: compressionQuality, opaqueMode: opaqueMode)
}

private func compare(
    _ old: NSImage,
    _ new: NSImage,
    precision: Float,
    compressionQuality: CompressionQuality,
    opaqueMode: OpaqueMode = .auto
) -> String? {
    guard let oldCgImage = old.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        return "Reference image could not be loaded."
    }
    guard let newCgImage = new.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
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
    var oldBytes = [UInt8](repeating: 0, count: byteCount)
    guard let oldData = createImageContext(for: oldCgImage, data: &oldBytes)?.data else {
        return "Reference image's data could not be loaded."
    }
    if let newContext = createImageContext(for: newCgImage), let newData = newContext.data {
        if memcmp(oldData, newData, byteCount) == 0 { return nil }
    }
    var newerBytes = [UInt8](repeating: 0, count: byteCount)

    guard
        let heicData = new.heicData(compressionQuality: compressionQuality, opaqueMode: opaqueMode),
        let newerCgImage = NSImage(data: heicData)?.cgImage(forProposedRect: nil, context: nil, hints: nil),
        let newerContext = createImageContext(for: newerCgImage, data: &newerBytes),
        let newerData = newerContext.data
    else {
        return "Newly-taken snapshot's data could not be loaded."
    }
    if memcmp(oldData, newerData, byteCount) == 0 { return nil }
    if precision >= 1 {
        return "Newly-taken snapshot does not match reference."
    }

    // Use shared helper with early exit optimization
    let (passed, actualPrecision) = comparePixelBytes(
        oldBytes,
        newerBytes,
        byteCount: byteCount,
        precision: precision
    )
    if !passed {
        return "Actual image precision \(actualPrecision) is less than required \(precision)"
    }
    return nil
}

private func diffNSImage(_ old: NSImage, _ new: NSImage) -> NSImage {
    let oldCiImage = CIImage(cgImage: old.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
    let newCiImage = CIImage(cgImage: new.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
    let differenceFilter = CIFilter(name: "CIDifferenceBlendMode")!
    differenceFilter.setValue(oldCiImage, forKey: kCIInputImageKey)
    differenceFilter.setValue(newCiImage, forKey: kCIInputBackgroundImageKey)
    let maxSize = CGSize(
        width: max(old.size.width, new.size.width),
        height: max(old.size.height, new.size.height)
    )
    let rep = NSCIImageRep(ciImage: differenceFilter.outputImage!)
    let difference = NSImage(size: maxSize)
    difference.addRepresentation(rep)
    return difference
}
#endif
