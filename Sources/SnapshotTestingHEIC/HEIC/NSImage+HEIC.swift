#if os(macOS)
    import AVFoundation
    import Cocoa
    import ImageIO

    /// Checks if HEIC encoding is available on the current system.
    /// Returns false on systems without hardware HEVC encoder (e.g., GitHub Actions runners).
    public func isHEICEncodingAvailable() -> Bool {
        // Create a minimal 1x1 test image
        let testImage = NSImage(size: NSSize(width: 1, height: 1))
        testImage.lockFocus()
        NSColor.white.setFill()
        NSRect(origin: .zero, size: testImage.size).fill()
        testImage.unlockFocus()

        // Try to encode it as HEIC
        return testImage.heicData(compressionQuality: .lossless) != nil
    }

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

            guard
                let imageDestination = CGImageDestinationCreateWithData(
                    data,
                    AVFileType.heic as CFString,
                    1,
                    nil
                )
            else { return nil }

            guard
                let cgImage = cgImage(
                    forProposedRect: nil,
                    context: nil,
                    hints: nil
                )
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
