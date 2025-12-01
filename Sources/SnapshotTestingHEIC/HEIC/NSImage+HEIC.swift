#if os(macOS)
import AVFoundation
import Cocoa
import ImageIO

extension NSImage {
    /// Checks if the image is opaque (has no alpha channel)
    var isOpaqueImage: Bool {
        guard let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil) else { return true }
        let alphaInfo = cgImage.alphaInfo
        switch alphaInfo {
        case .none, .noneSkipFirst, .noneSkipLast:
            return true
        default:
            return false
        }
    }

    func heicData(compressionQuality: CompressionQuality, opaqueMode: OpaqueMode = .auto) -> Data? {
        let data = NSMutableData()

        guard let imageDestination = CGImageDestinationCreateWithData(
            data, AVFileType.heic as CFString, 1, nil
        )
        else { return nil }

        guard let cgImage = cgImage(forProposedRect: nil,
                                    context: nil,
                                    hints: nil)
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

        var options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality.rawValue
        ]

        // Set alpha handling to prevent "opaque image with AlphaLast" warning
        if shouldBeOpaque {
            options[kCGImagePropertyHasAlpha] = false
        }

        CGImageDestinationAddImage(imageDestination, cgImage, options as CFDictionary)

        guard CGImageDestinationFinalize(imageDestination) else { return nil }

        return data as Data
    }
}
#endif
