import os
import Combine
import SwiftUI
import Spatial
import RealityKit

// MARK: - DebugVisualization
/// 调试可视化模块
/// 提供3D空间中的点、射线、坐标轴的可视化功能
/// 用于开发和调试阶段的视觉辅助

/// 点可视化信号
@MainActor
public let debugVisualization = PassthroughSubject<(String, Point3D, String), Never>() // displayName, point, tag

/// 射线可视化信号
@MainActor
public let debugRayVisualization = PassthroughSubject<(String, (Point3D, Vector3D), String), Never>() // displayName, ray(start,to), tag

/// 坐标轴可视化信号
@MainActor
public let debugAxisVisualization = PassthroughSubject<(String, Transform, String), Never>() // displayName, axis, tag

// MARK: - DebugVisualizationModel
/// 调试可视化模型
/// 管理3D空间中的可视化实体，支持点、射线、坐标轴的显示
/// 每个可视化元素都有独立的颜色和标签
@MainActor
@Observable
public class DebugVisualizationModel {
    private let baseEntity = Entity()
    private var entities: [String: Entity] = [:]
    private var colors: [UIColor] = [
        .black, .darkGray, .lightGray, .white, .gray,
        .red, .green, .blue, .cyan, .yellow,
        .magenta, .orange, .purple, .brown
    ]
    
    public init() {}
    
    public func createEntity() -> Entity {
        return baseEntity
    }
    
    public func onReceived(tag: String, displayName: String, point: Point3D) {
        if let exist = entities[tag] {
            exist.setPosition(SIMD3<Float>(point.vector), relativeTo: nil)
        } else {
            guard let randomColor = colors.randomElement() else {
                fatalError("不应该取不到")
            }
            let sphereRadius: Float = 0.05
            let newEntity = ModelEntity(mesh: .generateSphere(radius: sphereRadius), materials: [SimpleMaterial(color: randomColor, isMetallic: false)])
            entities[tag] = newEntity
            let displayNameView = Entity()
            displayNameView.components.set(ViewAttachmentComponent(rootView: Text(displayName).padding().background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))))
            displayNameView.position = [0, 0.1, 0]
            displayNameView.components.set(BillboardComponent())
            newEntity.addChild(displayNameView)
            baseEntity.addChild(newEntity)
            newEntity.setPosition(SIMD3<Float>(point.vector), relativeTo: nil)
        }
    }
    
    private func quaternionFromUpVector(to targetVector: simd_float3) -> simd_quatf? {
        let up = simd_float3(0, 1, 0)
        let target = normalize(targetVector)
        
        if length(target) < Float.ulpOfOne {
            return nil
        }
        
        let dotValue = dot(up, target)
        if abs(dotValue + 1.0) < 1e-6 {
            let axis = normalize(cross(up, simd_float3(1, 0, 0)))
            if length(axis) < 1e-6 {
                return simd_quatf(angle: .pi, axis: normalize(cross(up, simd_float3(0, 0, 1))))
            }
            return simd_quatf(angle: .pi, axis: axis)
        }
        
        let cosTheta = dotValue
        let axis = normalize(cross(up, target))
        let angle = acos(cosTheta)
        
        return simd_quatf(angle: angle, axis: axis)
    }
    
    public func onReceived(tag: String, displayName: String, ray: (Point3D, Vector3D)) {
        let (start, to) = ray
        guard let rotation = quaternionFromUpVector(to: SIMD3<Float>(to.vector)) else {
            logWithInterval("不合法的指向", tag: "DebugVisualizationModel.onReceived.ray")
            return
        }
        if let exist = entities[tag] {
            exist.setPosition(SIMD3<Float>(start.vector), relativeTo: nil)
            exist.setOrientation(rotation, relativeTo: nil)
        } else {
            let newEntity = RayVisualizer.make()
            entities[tag] = newEntity
            let displayNameView = Entity()
            displayNameView.components.set(ViewAttachmentComponent(rootView: Text(displayName).padding().background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))))
            displayNameView.position = [0, 0.1, 0]
            displayNameView.components.set(BillboardComponent())
            newEntity.addChild(displayNameView)
            baseEntity.addChild(newEntity)
            newEntity.setPosition(SIMD3<Float>(start.vector), relativeTo: nil)
            newEntity.setOrientation(rotation, relativeTo: nil)
        }
    }
    
    public func onReceived(tag: String, displayName: String, axis: Transform) {
        if let exist = entities[tag] {
            exist.setTransformMatrix(axis.matrix, relativeTo: nil)
        } else {
            let newEntity = AxisVisualizer.make()
            entities[tag] = newEntity
            let displayNameView = Entity()
            displayNameView.components.set(ViewAttachmentComponent(rootView: Text(displayName).padding().background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))))
            displayNameView.position = [0, 0.1, 0]
            displayNameView.components.set(BillboardComponent())
            newEntity.addChild(displayNameView)
            baseEntity.addChild(newEntity)
            newEntity.setTransformMatrix(axis.matrix, relativeTo: nil)
        }
    }
    
    // MARK: - RayVisualizer
    /// 射线可视化器
    @MainActor
    public struct RayVisualizer {
        public static func make() -> Entity {
            let outer = Entity()
            let width: Float = 0.0025
            let length: Float = 10
            let radius: Float = 0.005
            let rayMesh = MeshResource.generateBox(size: [width, length, width])
            let rayMaterial = UnlitMaterial(color: .systemGreen)
            let inner = ModelEntity(mesh: rayMesh, materials: [rayMaterial])
            inner.position = [0, 0.5 * length, 0]
            let originMesh = MeshResource.generateSphere(radius: radius)
            let originMaterial = UnlitMaterial(color: .white)
            let originEntity = ModelEntity(mesh: originMesh, materials: [originMaterial])
            outer.addChild(originEntity)
            outer.addChild(inner)
            return outer
        }
    }
    
    // MARK: - AxisVisualizer
    /// 坐标轴可视化器
    @MainActor
    public struct AxisVisualizer {
        public static func make() -> Entity {
            let entity = Entity()
            let width: Float = 0.0025
            let length: Float = 0.1
            let radius: Float = 0.005

            let xAxisMesh = MeshResource.generateBox(size: [length, width, width])
            let xAxisMaterial = UnlitMaterial(color: .systemRed)
            let xAxisEntity = ModelEntity(mesh: xAxisMesh, materials: [xAxisMaterial])
            xAxisEntity.position = [0.5 * length, 0, 0]
            entity.addChild(xAxisEntity)

            let yAxisMesh = MeshResource.generateBox(size: [width, length, width])
            let yAxisMaterial = UnlitMaterial(color: .systemGreen)
            let yAxisEntity = ModelEntity(mesh: yAxisMesh, materials: [yAxisMaterial])
            yAxisEntity.position = [0, 0.5 * length, 0]
            entity.addChild(yAxisEntity)

            let zAxisMesh = MeshResource.generateBox(size: [width, width, length])
            let zAxisMaterial = UnlitMaterial(color: .systemBlue)
            let zAxisEntity = ModelEntity(mesh: zAxisMesh, materials: [zAxisMaterial])
            zAxisEntity.position = [0, 0, 0.5 * length]
            entity.addChild(zAxisEntity)

            let originMesh = MeshResource.generateSphere(radius: radius)
            let originMaterial = UnlitMaterial(color: .white)
            let originEntity = ModelEntity(mesh: originMesh, materials: [originMaterial])
            entity.addChild(originEntity)

            return entity
        }
    }
}

// MARK: - EnableDebugVis
/// 启用调试可视化修饰器
/// 为视图添加调试可视化功能，接收并显示点、射线、坐标轴
public struct EnableDebugVis: ViewModifier {
    @State
    public var baseEntity: Entity
    @State
    private var debugVisMod = DebugVisualizationModel()
    
    public init(baseEntity: Entity) {
        self.baseEntity = baseEntity
    }
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                os_log("onAppear")
                baseEntity.addChild(debugVisMod.createEntity())
            }
            .onReceive(debugVisualization) { (displayName, point, tag) in
                debugVisMod.onReceived(tag: tag, displayName: displayName, point: point)
            }
            .onReceive(debugAxisVisualization) { (displayName, axis, tag) in
                debugVisMod.onReceived(tag: tag, displayName: displayName, axis: axis)
            }
            .onReceive(debugRayVisualization) { (displayName, ray, tag) in
                debugVisMod.onReceived(tag: tag, displayName: displayName, ray: ray)
            }
    }
}
