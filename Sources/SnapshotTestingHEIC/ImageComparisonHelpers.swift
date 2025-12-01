#if os(iOS) || os(tvOS) || os(macOS)
import Foundation
import CoreGraphics

// MARK: - Image Context Constants

/// Color space for consistent image comparison across platforms
let imageContextColorSpace = CGColorSpace(name: CGColorSpace.sRGB)

/// Bits per component for RGBA images
let imageContextBitsPerComponent = 8

/// Bytes per pixel for RGBA images (4 channels: R, G, B, A)
let imageContextBytesPerPixel = 4

// MARK: - Pixel Comparison

/// Compares two byte arrays with early exit optimization when threshold is exceeded.
///
/// - Parameters:
///   - oldBytes: Reference image bytes
///   - newBytes: New image bytes
///   - byteCount: Total number of bytes to compare
///   - precision: Required precision (0-1), where 1 means 100% match required
/// - Returns: Tuple containing (passed: Bool, actualPrecision: Float)
func comparePixelBytes(
    _ oldBytes: UnsafePointer<UInt8>,
    _ newBytes: UnsafePointer<UInt8>,
    byteCount: Int,
    precision: Float
) -> (passed: Bool, actualPrecision: Float) {
    let threshold = Int((1 - precision) * Float(byteCount))
    var differentByteCount = 0

    for offset in 0..<byteCount {
        if oldBytes[offset] != newBytes[offset] {
            differentByteCount += 1
        }
        // Early exit optimization - stop comparing once we know the result
        if differentByteCount > threshold {
            let actualPrecision = 1 - Float(differentByteCount) / Float(byteCount)
            return (false, actualPrecision)
        }
    }

    let actualPrecision = 1 - Float(differentByteCount) / Float(byteCount)
    return (differentByteCount <= threshold, actualPrecision)
}

// MARK: - CGContext Creation

/// Creates a CGContext for the given CGImage using consistent sRGB color space.
///
/// - Parameters:
///   - cgImage: The source CGImage to create context for
///   - data: Optional buffer to store pixel data. If nil, context allocates its own buffer.
/// - Returns: A CGContext configured for the image, or nil if creation fails
func createImageContext(for cgImage: CGImage, data: UnsafeMutableRawPointer? = nil) -> CGContext? {
    let bytesPerRow = cgImage.width * imageContextBytesPerPixel
    guard
        let colorSpace = imageContextColorSpace,
        let context = CGContext(
            data: data,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: imageContextBitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    else { return nil }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
    return context
}
#endif
