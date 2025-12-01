#if os(iOS) || os(tvOS)
import AVFoundation
import ImageIO
import UIKit

@available(tvOSApplicationExtension 11.0, *)
extension UIImage {
    /// Checks if the image is opaque (has no alpha channel)
    var isOpaqueImage: Bool {
        guard let cgImage = cgImage else { return true }
        let alphaInfo = cgImage.alphaInfo
        switch alphaInfo {
        case .none, .noneSkipFirst, .noneSkipLast:
            return true
        default:
            return false
        }
    }

    func heicData(compressionQuality: CGFloat, opaqueMode: OpaqueMode = .auto) -> Data? {
        let data = NSMutableData()

        guard let imageDestination = CGImageDestinationCreateWithData(
            data, AVFileType.heic as CFString, 1, nil
        )
        else { return nil }

        guard let cgImage = cgImage
        else { return nil }

        // Determine if we should encode as opaque
        let shouldBeOpaque: Bool
        switch opaqueMode {
        case .auto:
            shouldBeOpaque = isOpaqueImage
        case .opaque:
            shouldBeOpaque = true
        case .transparent:
            shouldBeOpaque = false
        }

        var options: [CFString: Any] = [:]

        if compressionQuality < 1 {
            options[kCGImageDestinationLossyCompressionQuality] = compressionQuality
        }

        // Set alpha handling to prevent "opaque image with AlphaLast" warning
        if shouldBeOpaque {
            options[kCGImagePropertyHasAlpha] = false
        }

        CGImageDestinationAddImage(
            imageDestination,
            cgImage,
            options.isEmpty ? nil : options as CFDictionary
        )

        guard CGImageDestinationFinalize(imageDestination)
        else { return nil }

        return data as Data
    }
}
#endif
