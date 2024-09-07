#if os(iOS) || os(tvOS)
import AVFoundation
import UIKit

@available(tvOSApplicationExtension 11.0, *)
extension UIImage {
    func heicData(compressionQuality: CGFloat) -> Data? {
        let data = NSMutableData()

        guard let imageDestination = CGImageDestinationCreateWithData(
            data, AVFileType.heic as CFString, 1, nil
        )
        else { return nil }

        guard let cgImage = cgImage 
        else { return nil }

        let options: NSDictionary?
        if compressionQuality >= 1 {
            options = nil
        } else {
            options = [
                kCGImageDestinationLossyCompressionQuality: compressionQuality
            ]
        }

        CGImageDestinationAddImage(imageDestination, cgImage, options)

        guard CGImageDestinationFinalize(imageDestination) 
        else { return nil }

        return data as Data
    }
}
#endif
