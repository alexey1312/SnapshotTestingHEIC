import Foundation

public struct CompressionQuality: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Float
    
    public let value: Float
    
    public init(floatLiteral value: Float) {
        self.value = value
    }
    
    public init(_ value: Float) {
        self.value = value
    }

    public static var lossless: CompressionQuality {
        return 1.0
    }

    public static var low: CompressionQuality {
        return 0.8
    }

    public static var medium: CompressionQuality {
        return 0.5
    }

    public static var high: CompressionQuality {
        return 0.2
    }

    public static var maximum: CompressionQuality {
        return 0.0
    }
}
