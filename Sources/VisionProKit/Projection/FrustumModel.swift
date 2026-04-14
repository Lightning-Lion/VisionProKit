import Foundation
import RealityKit
import Spatial

// MARK: - FrustumModel
/// 视锥体模型
/// 进行视锥体相关的计算，包括视锥体构造、射线求交等
/// 本类主要用于调试和可视化视锥体
/// 如果只是需要创建屏幕显示远平面，建议直接使用DirectScreenCalculator
public actor FrustumModel {
    private let perspectiveCameraData: PerspectiveCameraData
    
    public init(perspectiveCameraData: PerspectiveCameraData) {
        self.perspectiveCameraData = perspectiveCameraData
    }
    
    public struct FrustumGlobal: Equatable, Sendable {
        public var topLeft: Ray3D
        public var topRight: Ray3D
        public var bottomLeft: Ray3D
        public var bottomRight: Ray3D
        public var opticalAxis: Ray3D
        
        public func toDeviceLocal(devicePose: Transform) -> FrustumDeviceLocal {
            return FrustumDeviceLocal(
                topLeft: Ray3D.toDeviceLocalRay(globalRay: topLeft, devicePose: devicePose),
                topRight: Ray3D.toDeviceLocalRay(globalRay: topRight, devicePose: devicePose),
                bottomLeft: Ray3D.toDeviceLocalRay(globalRay: bottomLeft, devicePose: devicePose),
                bottomRight: Ray3D.toDeviceLocalRay(globalRay: bottomRight, devicePose: devicePose),
                opticalAxis: Ray3D.toDeviceLocalRay(globalRay: opticalAxis, devicePose: devicePose)
            )
        }
    }
    
    public struct FrustumDeviceLocal: Equatable, Sendable {
        public var topLeft: Ray3D
        public var topRight: Ray3D
        public var bottomLeft: Ray3D
        public var bottomRight: Ray3D
        public var opticalAxis: Ray3D
    }
    
    /// 表示视锥体与某平面相交的四个角点
    public struct FrustumHitPlaneCorners: Sendable {
        public var topLeft: Point3D
        public var topRight: Point3D
        public var bottomLeft: Point3D
        public var bottomRight: Point3D
    }
    
    public func getFrustumGlobal(eye: Device.Camera) async -> FrustumGlobal {
        let topLeftRay = await CameraToWorld(perspectiveCameraData: perspectiveCameraData).cameraPointToWorldRay(cameraPoint: Point2D(x: 0, y: 0), eye: eye)
        let topRightRay = await CameraToWorld(perspectiveCameraData: perspectiveCameraData).cameraPointToWorldRay(cameraPoint: Point2D(x: perspectiveCameraData.resolution.width, y: 0), eye: eye)
        let bottomLeftRay = await CameraToWorld(perspectiveCameraData: perspectiveCameraData).cameraPointToWorldRay(cameraPoint: Point2D(x: 0, y: perspectiveCameraData.resolution.height), eye: eye)
        let bottomRightRay = await CameraToWorld(perspectiveCameraData: perspectiveCameraData).cameraPointToWorldRay(cameraPoint: Point2D(x: perspectiveCameraData.resolution.width, y: perspectiveCameraData.resolution.height), eye: eye)
        let opticalAxis = await getOpticalAxis(eye: eye)
        return FrustumGlobal(topLeft: topLeftRay, topRight: topRightRay, bottomLeft: bottomLeftRay, bottomRight: bottomRightRay, opticalAxis: opticalAxis)
    }
    
    // 获取视锥体与“与视锥体光轴垂直、指定距离平面”的交点
    public func getCornerPoints(frustum: FrustumGlobal, distance: Double, eye: Device.Camera) throws -> FrustumHitPlaneCorners {
        let opticalAxis = frustum.opticalAxis
        let plane = try PlaneOnOpticalAxis(opticalAxis: opticalAxis, distance: distance)
        let topLeft = try calculateIntersection(ray: frustum.topLeft, plane: plane)
        let topRight = try calculateIntersection(ray: frustum.topRight, plane: plane)
        let bottomLeft = try calculateIntersection(ray: frustum.bottomLeft, plane: plane)
        let bottomRight = try calculateIntersection(ray: frustum.bottomRight, plane: plane)
        return FrustumHitPlaneCorners(topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight)
    }
    
    private func getOpticalAxis(eye: Device.Camera) async -> Ray3D {
        // 在我们的透视相机模型中，光心就是视口的正中心
        let opticalCenter = Point2D(x: perspectiveCameraData.resolution.width / 2, y: perspectiveCameraData.resolution.height / 2)
        return await CameraToWorld(perspectiveCameraData: perspectiveCameraData).cameraPointToWorldRay(cameraPoint: opticalCenter, eye: eye)
    }
    
    /// 光轴上的平面
    /// 表示垂直于光轴、位于指定距离处的平面
    fileprivate struct PlaneOnOpticalAxis {
        let normal: SIMD3<Double>
        let d: Double
        
        init(opticalAxis ray: Ray3D, distance: Double) throws {
            guard distance > 0 else { throw PlaneError.invalidDistance }
            self.normal = -ray.direction.vector
            let pointOnPlane = ray.origin + distance * ray.direction
            self.d = dot(normal, pointOnPlane.vector)
        }
    }
    
    public enum PlaneError: Error, LocalizedError {
        case invalidDistance
        public var errorDescription: String? {
            switch self {
            case .invalidDistance: return "距离必须大于0"
            }
        }
    }
    
    /// 计算射线与平面（视锥体沿着光轴指定距离的平面）的交点
    private func calculateIntersection(ray: Ray3D, plane: PlaneOnOpticalAxis) throws -> Point3D {
        let denominator = dot(ray.direction.vector, plane.normal)
        if abs(denominator) < 1e-10 {
            throw GetIntersectionError.notValidRay
        }
        let numerator = plane.d - dot(plane.normal, ray.origin.vector)
        let t = numerator / denominator
        if t < 0 {
            throw GetIntersectionError.noValidIntersection
        }
        return ray.origin + t * ray.direction
    }
    
    public enum GetIntersectionError: Error, LocalizedError {
        case notValidRay
        case noValidIntersection
        public var errorDescription: String? {
            switch self {
            case .notValidRay: "传入的射线不合法"
            case .noValidIntersection: "没有合法交点"
            }
        }
    }
}

nonisolated
public extension Ray3D {
    static func toDeviceLocalRay(globalRay: Ray3D, devicePose: Transform) -> Ray3D {
        let inversePose = devicePose.matrixDouble.inverse
        let localOrigin = inversePose * simd_double4(globalRay.origin.vector, 1.0)
        let rotationInverse = Transform(matrixDouble: inversePose).matrixDouble.rotationMatrix
        let localDirection = rotationInverse * globalRay.direction.vector
        return Ray3D(origin: simd_double3(localOrigin.x, localOrigin.y, localOrigin.z),
                     direction: simd_normalize(localDirection))
    }
}
