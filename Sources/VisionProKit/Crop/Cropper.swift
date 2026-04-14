import os
import CoreImage
import SwiftUI
import RealityKit

// MARK: - QuadrilateralCropper
/// 四边形裁切器
/// 从相机照片中截取出取景框的部分
nonisolated
public struct QuadrilateralCropper {
    
    public init() {}
    
    public struct Viewfinder2DCornersPose: Sendable {
        public var topLeft: Point2D
        public var topRight: Point2D
        public var bottomLeft: Point2D
        public var bottomRight: Point2D
        
        public init(topLeft: Point2D, topRight: Point2D, bottomLeft: Point2D, bottomRight: Point2D) {
            self.topLeft = topLeft
            self.topRight = topRight
            self.bottomLeft = bottomLeft
            self.bottomRight = bottomRight
        }
        
        public func toQuadrilateral2D() -> Quadrilateral2D {
            Quadrilateral2D(
                topLeft: topLeft.toCGPoint(),
                topRight: topRight.toCGPoint(),
                bottomLeft: bottomLeft.toCGPoint(),
                bottomRight: bottomRight.toCGPoint()
            )
        }
    }
    
    // 从图像中裁剪下一个四边形并且扭曲到矩形，
    // 不保证固定的扭曲策略（生成的矩形图像纵横比随机），外界需要自行设置渲染时的正确画布尺寸并配合.reasizeable()，
    // 实践中，这个四边形本质上是3D中一个矩形的2D投影，因此外界画布纵横比就是3D矩形的纵横比。
    public func cropInViewfinderPart(
        image: CGImage,
        twoDCorners: QuadrilateralCropper.Viewfinder2DCornersPose,
        strictness: CropStrictness
    ) async throws -> CGImage {
        let quadrilateral2D = twoDCorners.toQuadrilateral2D()
        let imageSize = CGSize(width: image.width, height: image.height)
        let ciQuadrilateral = quadrilateral2D.toCoreImageCoordinates(in: imageSize)
        try validateQuadrilateral(ciQuadrilateral, in: imageSize, with: strictness)
        let cropImage = try await QuadrilateralCropActor().cropQuadrilateral(
            quadrilateral: quadrilateral2D,
            image: image,
            strictness: strictness
        )
        return cropImage
    }
    
    // 验证四边形是否在图像内
    // 如果采用宽松验证，可能出现完全透明的输出
    // 如果采用normal验证，可能会出现部分（比如一个角）透明的输出
    // 如果采用严格验证，一定是完全有画面的
    private func validateQuadrilateral(
        _ quadrilateral: Quadrilateral2DCoreImageCoordinates,
        in imageSize: CGSize,
        with strictness: CropStrictness
    ) throws {
        let imageRect = CGRect(origin: .zero, size: imageSize)
        switch strictness {
        case .loose:
            break
        case .normal:
            // 普通模式：检查四边形是否与图片有相交
            guard quadrilateral.intersects(with: imageRect) else {
                throw QuadrilateralCropActor.CropQuadrilateralError.noIntersectionWithImage
            }
        case .strict:
            guard quadrilateral.isCompletelyInside(imageRect) else {
                throw QuadrilateralCropActor.CropQuadrilateralError.quadrilateralNotFullyInsideImage
            }
        }
    }
    
    public enum CropStrictness: Sendable {
        case loose
        case normal
        case strict
        
        public var description: String {
            switch self {
            case .loose: return "宽松模式（可能返回透明图像）"
            case .normal: return "普通模式（要求有交集）"
            case .strict: return "严格模式（完全包含在图片内）"
            }
        }
    }
}

// MARK: - QuadrilateralCropActor
// 我是负责把QuadrilateralCropper里的实际工作给放到后台线程做
public actor QuadrilateralCropActor {
    public init() {}
    
    // 传入一个四边形，裁切出来，投影为矩形
    public func cropQuadrilateral(
        quadrilateral: Quadrilateral2D,
        image: CGImage,
        strictness: QuadrilateralCropper.CropStrictness
    ) throws -> CGImage {
        do {
            let inputCIImage = CIImage(cgImage: image)
            // 将四边形坐标转换为Core Image坐标系（Y轴翻转）
            let ciQuadrilateral = quadrilateral.toCoreImageCoordinates(in: CGSize(width: image.width, height: image.height))
            let outputCIImage = try perspectiveTransform(inputImage: inputCIImage, quadrilateral: ciQuadrilateral, strictness: strictness)
            let outputCGImage = try ciImageToCGImage(ciImage: outputCIImage)
            return outputCGImage
        } catch {
            os_log("\(error.localizedDescription)")
            throw CropQuadrilateralError.cropFailed
        }
    }
    
    // 应用透视变换的核心函数
    // 我的行为表现就应该和
    // Imgproc.getPerspectiveTransform
    // 然后
    // Imgproc.warpPerspective(
    // 一样，其中src就是我这里得到的设置的值，dst就是目标画布的边角（目标画布的尺寸、长宽比不重要，反正最终上屏的时候是设置了width、height的，拉伸到对应值即可）
    // 如果呈现区域超出原图，会呈现透明
    // CIFilter.perspectiveCorrection有个问题，不支持负数（超出图像边界）的顶点区域，因此需要做一下包装
    private func perspectiveTransform(
        inputImage: CIImage,
        quadrilateral ciQuadrilateral: Quadrilateral2DCoreImageCoordinates,
        strictness: QuadrilateralCropper.CropStrictness
    ) throws -> CIImage {
        // 扩展图像并调整坐标
        let (extendedImage, adjustedQuad) = try extendImageIfNeeded(inputImage: inputImage, quadrilateral: ciQuadrilateral)
        // 执行透视变换
        let perspectiveTransformFilter = CIFilter.perspectiveCorrection()
        perspectiveTransformFilter.inputImage = extendedImage
        perspectiveTransformFilter.topLeft = adjustedQuad.topLeft
        perspectiveTransformFilter.topRight = adjustedQuad.topRight
        perspectiveTransformFilter.bottomLeft = adjustedQuad.bottomLeft
        perspectiveTransformFilter.bottomRight = adjustedQuad.bottomRight
        guard let outputImage = perspectiveTransformFilter.outputImage else {
            throw PerspectiveTransformError.filterFailed
        }
        return outputImage
    }
    
    // 因为裁切区域可能在图像外，所以会裁出空白的
    // 但因为CIFilter.perspectiveCorrection不支持往图像外裁剪
    // 我们需要提前扩展图像，把空白部分留出来
    private func extendImageIfNeeded(
        inputImage: CIImage,
        quadrilateral ciQuadrilateral: Quadrilateral2DCoreImageCoordinates
    ) throws -> (extendedImage: CIImage, adjustedQuadrilateral: Quadrilateral2DCoreImageCoordinates) {
        let imageBounds = CGRect(x: 0, y: 0, width: inputImage.extent.width, height: inputImage.extent.height)
        let quadBounds = ciQuadrilateral.boundingRect()
        
        let allPointsInside = [ciQuadrilateral.topLeft, ciQuadrilateral.topRight, ciQuadrilateral.bottomLeft, ciQuadrilateral.bottomRight].allSatisfy { imageBounds.contains($0) }
        
        if allPointsInside {
            return (inputImage, ciQuadrilateral)
        }
        
        let minX = min(0, quadBounds.minX)
        let minY = min(0, quadBounds.minY)
        let maxX = max(imageBounds.maxX, quadBounds.maxX)
        let maxY = max(imageBounds.maxY, quadBounds.maxY)
        
        let newBounds = CGRect(x: 0, y: 0, width: maxX - minX, height: maxY - minY)
        let backgroundImage = CIImage(color: CIColor.clear).cropped(to: newBounds)
        let translateX = -minX
        let translateY = -minY
        let transform = CGAffineTransform(translationX: translateX, y: translateY)
        let transformedImage = inputImage.transformed(by: transform)
        let extendedImage = transformedImage.composited(over: backgroundImage)
        let adjustedQuadrilateral = ciQuadrilateral.translatedBy(dx: translateX, dy: translateY)
        
        return (extendedImage, adjustedQuadrilateral)
    }

    private func ciImageToCGImage(ciImage: CIImage) throws -> CGImage {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            throw CIImageCreateCGImageError()
        }
        return cgImage
    }
    
    public enum CropQuadrilateralError: LocalizedError, Sendable {
        case cropFailed
        case noIntersectionWithImage
        case quadrilateralNotFullyInsideImage
        public var errorDescription: String? {
            switch self {
            case .cropFailed: return "裁切出取景框四边形失败"
            case .noIntersectionWithImage: return "四边形与图片没有交集"
            case .quadrilateralNotFullyInsideImage: return "四边形没有完全包含在图片内"
            }
        }
    }

    public enum PerspectiveTransformError: Error {
        case filterFailed
        case extentCalculationFailed
    }
    
    public struct CIImageCreateCGImageError: LocalizedError {
        public var errorDescription: String? { "CIImage 转换 CGImage 失败" }
    }
}
