#if os(iOS) || os(tvOS)
import UIKit
import XCTest
@testable import SnapshotTesting

public extension Diffing where Value == UIImage {
    /// A pixel-diffing strategy for UIImage's which requires a 100% match.
    static let imageHEIC = Diffing.imageHEIC(precision: 1, scale: nil, compressionQuality: .lossless)
    
    /// A pixel-diffing strategy for UIImage that allows customizing how precise the matching must be.
    ///
    /// - Parameter precision: A value between 0 and 1, where 1 means the images must match 100% of their pixels.
    /// - Parameter scale: Scale to use when loading the reference image from disk. If `nil` or the `UITraitCollection`s
    /// default value of `0.0`, the screens scale is used.
    /// - Parameter compressionQuality: The desired compression quality to use when writing to an image destination.
    /// - Returns: A new diffing strategy.
    static func imageHEIC(
        precision: Float,
        scale: CGFloat?,
        compressionQuality: CompressionQuality = .lossless
    ) -> Diffing {
        let imageScale: CGFloat
        if let scale = scale, scale != 0.0 {
            imageScale = scale
        } else {
            imageScale = UIScreen.main.scale
        }
        
        return Diffing(
            toData: {
                if #available(tvOSApplicationExtension 11.0, *) {
                    return $0.heicData(compressionQuality: compressionQuality) ?? emptyImage()
                        .heicData(compressionQuality: compressionQuality)!
                } else {
                    return $0.pngData() ?? emptyImage().pngData()!
                }
            },
            fromData: { UIImage(data: $0, scale: imageScale)! }
        ) { old, new in
            guard !compare(old, new, precision: precision, compressionQuality: compressionQuality)
            else { return nil }
            let difference = diffUIImage(old, new)
            let message = new.size == old.size
            ? "Newly-taken snapshot does not match reference."
            : "Newly-taken snapshot@\(new.size) does not match reference@\(old.size)."
            let oldAttachment = XCTAttachment(image: old)
            oldAttachment.name = "reference"
            let newAttachment = XCTAttachment(image: new)
            newAttachment.name = "failure"
            let differenceAttachment = XCTAttachment(image: difference)
            differenceAttachment.name = "difference"
            return (
                message,
                [oldAttachment, newAttachment, differenceAttachment]
            )
        }
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
        return .imageHEIC(precision: 1, scale: nil)
    }
    
    /// A snapshot strategy for comparing images based on pixel equality.
    ///
    /// - Parameter precision: The percentage of pixels that must match.
    /// - Parameter scale: The scale of the reference image stored on disk.
    /// - Parameter compressionQuality: The desired compression quality to use when writing to an image destination.
    static func imageHEIC(
        precision: Float,
        scale: CGFloat?,
        compressionQuality: CompressionQuality = .lossless
    ) -> Snapshotting {
        let snapshotting: Snapshotting
        
        if #available(tvOSApplicationExtension 11.0, *) {
            snapshotting = Snapshotting(
                pathExtension: "heic",
                diffing: Diffing<UIImage>
                    .imageHEIC(precision: precision, scale: scale, compressionQuality: compressionQuality)
            )
        } else {
            snapshotting = Snapshotting(
                pathExtension: "png",
                diffing: Diffing<UIImage>.image(precision: precision, scale: scale)
            )
        }
        
        return snapshotting
    }
}

private func compare(
    _ old: UIImage,
    _ new: UIImage,
    precision: Float,
    compressionQuality: CompressionQuality
) -> Bool {
    guard let oldCgImage = old.cgImage else { return false }
    guard let newCgImage = new.cgImage else { return false }
    guard oldCgImage.width != 0 else { return false }
    guard newCgImage.width != 0 else { return false }
    guard oldCgImage.width == newCgImage.width else { return false }
    guard oldCgImage.height != 0 else { return false }
    guard newCgImage.height != 0 else { return false }
    guard oldCgImage.height == newCgImage.height else { return false }
    // Values between images may differ due to padding to multiple of 64 bytes per row,
    // because of that a freshly taken view snapshot may differ from one stored as HEIC.
    // At this point we're sure that size of both images is the same, so we can go with minimal `bytesPerRow` value
    // and use it to create contexts.
    let minBytesPerRow = min(oldCgImage.bytesPerRow, newCgImage.bytesPerRow)
    let byteCount = minBytesPerRow * oldCgImage.height
    
    var oldBytes = [UInt8](repeating: 0, count: byteCount)
    guard let oldContext = context(for: oldCgImage, bytesPerRow: minBytesPerRow, data: &oldBytes)
    else { return false }
    guard let oldData = oldContext.data else { return false }
    if let newContext = context(for: newCgImage, bytesPerRow: minBytesPerRow), let newData = newContext.data {
        if memcmp(oldData, newData, byteCount) == 0 { return true }
    }
    
    let newer: UIImage
    
    if #available(tvOSApplicationExtension 11.0, *) {
        newer = UIImage(data: new.heicData(compressionQuality: compressionQuality)!)!
    } else {
        newer = UIImage(data: new.pngData()!)!
    }
    
    guard let newerCgImage = newer.cgImage else { return false }
    var newerBytes = [UInt8](repeating: 0, count: byteCount)
    guard let newerContext = context(for: newerCgImage, bytesPerRow: minBytesPerRow, data: &newerBytes)
    else { return false }
    guard let newerData = newerContext.data else { return false }
    if memcmp(oldData, newerData, byteCount) == 0 { return true }
    if precision >= 1 { return false }
    var differentPixelCount = 0
    let threshold = 1 - precision
    for byte in 0 ..< byteCount {
        if oldBytes[byte] != newerBytes[byte] { differentPixelCount += 1 }
        if Float(differentPixelCount) / Float(byteCount) > threshold { return false }
    }
    return true
}

private func context(for cgImage: CGImage, bytesPerRow: Int, data: UnsafeMutableRawPointer? = nil) -> CGContext? {
    guard
        let space = cgImage.colorSpace,
        let context = CGContext(
            data: data,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: space,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    else { return nil }
    
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
    return context
}

private func diffUIImage(_ old: UIImage, _ new: UIImage) -> UIImage {
    let width = max(old.size.width, new.size.width)
    let height = max(old.size.height, new.size.height)
    UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), true, 0)
    new.draw(at: .zero)
    old.draw(at: .zero, blendMode: .difference, alpha: 1)
    let differenceImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return differenceImage
}
#endif
