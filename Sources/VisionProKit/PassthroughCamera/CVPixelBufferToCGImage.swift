import CoreImage
import CoreVideo

// MARK: - CVReadOnlyPixelBuffer Extension
/// CVPixelBuffer转CGImage扩展
/// 将ARKit提供的CVReadOnlyPixelBuffer转换为可用于渲染的CGImage
public extension CVReadOnlyPixelBuffer {
    func toCGImage(context: CIContext) async throws -> CGImage {
        try await CVPixelBufferToCGImageModel().convertToCGImage(buffer: self, context: context)
    }
}

// MARK: - CVPixelBufferToCGImageModel
/// CVPixelBuffer转CGImage模型
/// 在后台线程执行像素缓冲区到CGImage的转换
/// 避免阻塞主线程，提高性能
public actor CVPixelBufferToCGImageModel {
    public init() {}
    
    public func convertToCGImage(buffer: CVReadOnlyPixelBuffer, context: CIContext) throws -> CGImage {
        try buffer.withUnsafeBuffer { cvPixelBuffer in
            let ciImage = CIImage(cvPixelBuffer: cvPixelBuffer)
            
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                throw CVPixelBufferToCGImageError.failedToCreateCGImageFromCVPixelBuffer
            }
            return cgImage
        }
    }
    
    public enum CVPixelBufferToCGImageError: Error, LocalizedError {
        case failedToCreateCGImageFromCVPixelBuffer
        public var errorDescription: String? {
            switch self {
            case .failedToCreateCGImageFromCVPixelBuffer:
                "failedToCreateCGImageFromCVPixelBuffer"
            }
        }
    }
}
