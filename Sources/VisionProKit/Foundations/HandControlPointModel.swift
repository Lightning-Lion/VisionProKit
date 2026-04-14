import os
import SwiftUI
import ARKit
import RealityKit

// MARK: - HandControlPointModel
/// 手控点模型
/// 通过ARKit手部锚点获取大拇指与食指尖中心，作为交互控制点
@MainActor
@Observable
public class HandControlPointModel {
    private let leftHandIndexFingerTip = AnchorEntity(.hand(.left, location: .indexFingerTip))
    private let leftHandThumbTip = AnchorEntity(.hand(.left, location: .thumbTip))
    private let rightHandIndexFingerTip = AnchorEntity(.hand(.right, location: .indexFingerTip))
    private let rightHandThumbTip = AnchorEntity(.hand(.right, location: .thumbTip))
    private let spatialSession = SpatialTrackingSession()
    
    public init() {}
    
    public func run(baseEntity: Entity) async {
        let unavailable = await spatialSession.run(SpatialTrackingSession.Configuration(tracking: [.hand]))
        if let unavailable {
            guard unavailable.anchor.isEmpty else {
                fatalError("手势追踪开启失败")
            }
        }
        baseEntity.addChild(leftHandThumbTip)
        baseEntity.addChild(leftHandIndexFingerTip)
        baseEntity.addChild(rightHandThumbTip)
        baseEntity.addChild(rightHandIndexFingerTip)
        os_log("手势追踪运行中")
    }
    
    // 取大拇指和食指中心点
    public func getControlPoint(baseEntity: Entity) -> (Point3D, Point3D)? {
        guard let leftSIMD3Float = getLeftHandPosition(baseEntity: baseEntity),
              let rightSIMD3Float = getRightHandPosition(baseEntity: baseEntity) else {
            return nil
        }
        let left = PointAndVectorAndTransformConverter.simd3FloatToPoint3D(leftSIMD3Float)
        let right = PointAndVectorAndTransformConverter.simd3FloatToPoint3D(rightSIMD3Float)
        return (left, right)
    }
    
    private func getLeftHandPosition(baseEntity: Entity) -> SIMD3<Float>? {
        guard leftHandIndexFingerTip.isAnchored, leftHandThumbTip.isAnchored else {
            return nil
        }
        let indexPosition = Transform(matrix: leftHandIndexFingerTip.transformMatrix(relativeTo: baseEntity)).translation
        let thumbPosition = Transform(matrix: leftHandThumbTip.transformMatrix(relativeTo: baseEntity)).translation
        return (thumbPosition + indexPosition) / 2
    }
    
    private func getRightHandPosition(baseEntity: Entity) -> SIMD3<Float>? {
        guard rightHandIndexFingerTip.isAnchored, rightHandThumbTip.isAnchored else {
            return nil
        }
        let indexPosition = Transform(matrix: rightHandIndexFingerTip.transformMatrix(relativeTo: baseEntity)).translation
        let thumbPosition = Transform(matrix: rightHandThumbTip.transformMatrix(relativeTo: baseEntity)).translation
        return (thumbPosition + indexPosition) / 2
    }
}
