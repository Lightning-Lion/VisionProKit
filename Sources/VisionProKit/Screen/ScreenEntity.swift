import Combine
import SwiftUI
import RealityKit

// MARK: - buildScreenEntity
/// 构建屏幕实体
/// 创建一个用于显示双目相机画面的3D实体
public func buildScreenEntity(image: CGImage, screenPose: Transform, screenPhysicalSize: Size2D, visibleEye: Device.Camera, createMaterialFn: @escaping (CGImage, CGImage) async throws -> ShaderGraphMaterial, createTransparentFn: @escaping () async throws -> CGImage) async throws -> Entity {
    let entity = await Entity()
    await entity.setTransformMatrix(screenPose.matrix, relativeTo: nil)
    let stereoMaterial: ShaderGraphMaterial = try await {
        let clearMaterial = try await createTransparentFn()
        switch visibleEye {
        case .left:
            return try await createMaterialFn(image, clearMaterial)
        case .right:
            return try await createMaterialFn(clearMaterial, image)
        }
    }()
    await entity.components.set(ViewAttachmentComponent(rootView: ScreenEntityInnerB(image: stereoMaterial, imagePhysicalSize: screenPhysicalSize)))
    return entity
}

// MARK: - ScreenEntityInnerB
/// 屏幕实体内部视图
public struct ScreenEntityInnerB: View {
    public var image: ShaderGraphMaterial
    public var imagePhysicalSize: Size2D
    @PhysicalMetric(from: .meters)
    private var pointsPerMeter: CGFloat = 1
    private var width: CGFloat { pointsPerMeter * CGFloat(imagePhysicalSize.width) }
    private var height: CGFloat { pointsPerMeter * CGFloat(imagePhysicalSize.height) }
    
    public init(image: ShaderGraphMaterial, imagePhysicalSize: Size2D) {
        self.image = image
        self.imagePhysicalSize = imagePhysicalSize
    }
    
    public var body: some View {
        RealityView { content in
            let plane = ModelEntity(mesh: .generatePlane(width: Float(imagePhysicalSize.width), height: Float(imagePhysicalSize.height)), materials: [image])
            content.add(plane)
        }
        .frame(width: width, height: height, alignment: .center)
    }
}
