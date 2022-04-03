#if os(macOS)
import AVFoundation
import Cocoa

extension NSImage {
    func heicData(compressionQuality: CompressionQuality = .lossless) -> Data? {
        let data = NSMutableData()

        guard let imageDestination = CGImageDestinationCreateWithData(
            data, AVFileType.heic as CFString, 1, nil
        )
        else { return nil }

        guard let cgImage = cgImage(forProposedRect: nil,
                                    context: nil,
                                    hints: nil)
        else { return nil }

        let options: NSDictionary = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality.value
        ]

        CGImageDestinationAddImage(imageDestination, cgImage, options)

        guard CGImageDestinationFinalize(imageDestination) else { return nil }

        return data as Data
    }
}
#endif

