import Foundation

/// Controls how alpha channel is handled during HEIC encoding.
///
/// Using `.auto` (default) automatically detects if the image has transparency.
/// This prevents the "opaque image with AlphaLast" warning and reduces file size.
public enum OpaqueMode: Hashable, Sendable {
    /// Automatically detect based on image's alpha info (recommended)
    case auto
    /// Force opaque encoding (no alpha channel)
    case opaque
    /// Force transparent encoding (with alpha channel)
    case transparent
}

public enum CompressionQuality: Hashable, RawRepresentable {
    case lossless
    case low
    case medium
    case high
    case maximum
    case custom(CGFloat)

    public init?(rawValue: CGFloat) {
        switch rawValue {
        case 1.0:
            self = .lossless
        case 0.8:
            self = .low
        case 0.5:
            self = .medium
        case 0.2:
            self = .high
        case 0.0:
            self = .maximum
        default:
            self = .custom(rawValue)
        }
    }
    
    public var rawValue: CGFloat {
        switch self {
        case .lossless:
            return 1.0
        case .low:
            return 0.8
        case .medium:
            return 0.5
        case .high:
            return 0.2
        case .maximum:
            return 0.0
        case let .custom(value):
            return value
        }
    }
}
