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
        return .init(
            toData: { NSImageHEICRepresentation($0, compressionQuality: compressionQuality, opaqueMode: opaqueMode)! },
            fromData: { NSImage(data: $0)! }
        ) { old, new in
            guard !compare(old, new, precision: precision, compressionQuality: compressionQuality, opaqueMode: opaqueMode)
            else { return nil }
            let difference = diffNSImage(old, new)
            let message = new.size == old.size
            ? "Newly-taken snapshot does not match reference."
            : "Newly-taken snapshot@\(new.size) does not match reference@\(old.size)."

            // Note: XCTest may still produce "opaque image with AlphaLast" warnings
            // when saving attachments to xcresult. This is internal XCTest behavior
            // and cannot be suppressed. The warning is informational only.
            let oldAttachment = XCTAttachment(image: old)
            oldAttachment.name = "reference"
            oldAttachment.lifetime = .keepAlways

            let newAttachment = XCTAttachment(image: new)
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
) -> Bool {
    guard let oldCgImage = old.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
    guard let newCgImage = new.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
    guard oldCgImage.width != 0 else { return false }
    guard newCgImage.width != 0 else { return false }
    guard oldCgImage.width == newCgImage.width else { return false }
    guard oldCgImage.height != 0 else { return false }
    guard newCgImage.height != 0 else { return false }
    guard oldCgImage.height == newCgImage.height else { return false }
    guard let oldContext = context(for: oldCgImage) else { return false }
    guard let newContext = context(for: newCgImage) else { return false }
    guard let oldData = oldContext.data else { return false }
    guard let newData = newContext.data else { return false }
    let byteCount = oldContext.height * oldContext.bytesPerRow
    if memcmp(oldData, newData, byteCount) == 0 { return true }
    let newer = NSImage(data: NSImageHEICRepresentation(new, compressionQuality: compressionQuality, opaqueMode: opaqueMode)!)!
    guard let newerCgImage = newer.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return false }
    guard let newerContext = context(for: newerCgImage) else { return false }
    guard let newerData = newerContext.data else { return false }
    if memcmp(oldData, newerData, byteCount) == 0 { return true }
    if precision >= 1 { return false }
    let oldRep = NSBitmapImageRep(cgImage: oldCgImage)
    let newRep = NSBitmapImageRep(cgImage: newerCgImage)
    var differentPixelCount = 0
    let pixelCount = oldRep.pixelsWide * oldRep.pixelsHigh
    let threshold = (1 - precision) * Float(pixelCount)
    let p1: UnsafeMutablePointer<UInt8> = oldRep.bitmapData!
    let p2: UnsafeMutablePointer<UInt8> = newRep.bitmapData!
    for offset in 0 ..< pixelCount * 4 {
        if p1[offset] != p2[offset] {
            differentPixelCount += 1
        }
        if Float(differentPixelCount) > threshold { return false }
    }
    return true
}

private func context(for cgImage: CGImage) -> CGContext? {
    guard
        let space = cgImage.colorSpace,
        let context = CGContext(
            data: nil,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: cgImage.bytesPerRow,
            space: space,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    else { return nil }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
    return context
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
