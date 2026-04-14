import Foundation
import CoreGraphics
import SwiftUI

// MARK: - QuadrilateralVisualization
/// 在图片上绘制调试框
/// 比如我们通过手势在3D中确定了一个矩形，但我们希望先做一个2D可视化（在相机画面上可视化），
/// 这时候投影到2D就是四边形了（也可能是矩形或者梯形），就需要用我们这个类来绘制一个四边形；
/// 我只负责绘制，但如果你需要从图像上把这个四边形裁下来，就需要用到struct QuadrilateralCropper {}类了。
public struct QuadrilateralVisualization {
    public init() {}
    
    public func drawQuadrilateral(image: CGImage, quadrilateral: Quadrilateral2DCoreImageCoordinates) throws -> CGImage {
        let width = image.width
        let height = image.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            throw NSError(domain: "QuadrilateralDrawer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create graphics context"])
        }
        
        context.interpolationQuality = .high
        context.setShouldAntialias(true)
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // 设置四边形绘制线宽和颜色
        context.setLineWidth(10.0)
        context.setStrokeColor(UIColor.yellow.cgColor)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        
        context.beginPath()
        context.move(to: quadrilateral.topLeft)
        context.addLine(to: quadrilateral.topRight)
        context.addLine(to: quadrilateral.bottomRight)
        context.addLine(to: quadrilateral.bottomLeft)
        context.addLine(to: quadrilateral.topLeft)
        context.strokePath()
        
        guard let resultImage = context.makeImage() else {
            throw NSError(domain: "QuadrilateralDrawer", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to create output image"])
        }
        return resultImage
    }
}

extension CGRect: @retroactive CustomStringConvertible {
    public var description: String {
        String(format: "CGRect(x: %.2f, y: %.2f, width: %.2f, height: %.2f)", origin.x, origin.y, size.width, size.height)
    }
}
