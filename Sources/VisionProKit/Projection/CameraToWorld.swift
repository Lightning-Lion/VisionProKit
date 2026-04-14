import os
import SwiftUI
import Spatial
import ARKit
import RealityKit

// MARK: - CameraToWorld
/// 相机到世界坐标转换器
/// 计算相机像素点对应的世界坐标射线
/// 提供深度信息即可精确到3D点，也可直接用射线进行hitTest
public actor CameraToWorld {
    private var perspectiveCameraData: PerspectiveCameraData
    
    public init(perspectiveCameraData: PerspectiveCameraData) {
        self.perspectiveCameraData = perspectiveCameraData
    }
    
    /// 相机画面中的像素点 → 三维世界射线（针孔相机模型的逆变换）。
    ///
    /// 四步流程（log9.log 左眼像素 (1008, 420) 实测验证）：
    ///
    ///   ① Y轴翻转（图像 +Y向下 → 3D +Y向上）：
    ///       pixel_x = 1008.0（不变）
    ///       pixel_y = 1080 − 420.337 = 659.663
    ///
    ///   ② 反透视：投影到归一化平面（z=−1），内参的逆变换：
    ///       dir_x = (1008 − 960)  / 736.63 = 48 / 736.63 = 0.0652  ✅
    ///       dir_y = (659.663 − 540) / 736.63 = 119.663 / 736.63 = 0.1624  ✅
    ///       dir_z = −1.0（定义相机朝 −Z 看）
    ///       → 相机空间方向 = (0.0652, 0.1624, −1.0)
    ///
    ///   ③ 相机空间 → 世界空间（cameraPose × [dir | w=0]）：
    ///       w=0 表示方向向量，不受平移影响，只受相机旋转变换
    ///       经头部旋转变换后：世界方向 = (−0.0659, 0.0166, −0.9977)
    ///       注：y 分量从 0.1624 变为 0.0166，原因是头部有旋转偏转（靠后仰视）
    ///
    ///   ④ 射线原点 = cameraPose.col3（相机在世界中的位置）：
    ///       origin = (−0.0303, 0.8888, −0.1508)  ← 左眼世界位置 ✅
    ///
    ///   验证（沿射线走1m）：
    ///       origin + 1×dir = (−0.0962, 0.9053, −1.1484) ✅（可用 WorldToCamera 反投验证）
    ///
    /// - Parameters:
    ///   - cameraPoint: 像素坐标 (x, y)，左上角 (0,0)，右下角 (1920,1080)
    ///   - eye: 左眼或右眼
    /// - Returns: 原点和方向均在世界坐标系中的射线
    public func cameraPointToWorldRay(cameraPoint: Point2D, eye: Device.Camera) -> Ray3D {
        let point = SIMD2<Double>(cameraPoint)
        let cameraPose: double4x4 = {
            switch eye {
            case .left:
                perspectiveCameraData.leftEyeCameraPose.matrixDouble
            case .right:
                perspectiveCameraData.rightEyeCameraPose.matrixDouble
            }
        }()
        let resolution = perspectiveCameraData.resolution
        
        // 从内参矩阵中提取焦距 (fx, fy) 和主点 (cx, cy)，焦距的单位是像素而不是毫米
        let (fx, fy, cx, cy) = restoreIntrinsics(simpleIntrinsic: perspectiveCameraData.simpleIntrinsic, resolution: perspectiveCameraData.resolution)
        
        // 图像坐标系 +Y向下，3D坐标系 +Y向上，翻转 Y 轴
        // log9: pixel_y = 1080 - 420.337 = 659.663
        let pixel_x = point.x
        let pixel_y = resolution.height - point.y
        // 反透视投影到 z=-1 归一化平面（内参的逆变换）
        // log9: x=(1008-960)/736.63=0.0652  y=(659.663-540)/736.63=0.1624  z=-1 ✅
        let cameraSpacePoint = SIMD3<Double>(
            (pixel_x - cx) / fx,
            (pixel_y - cy) / fy,
            -1.0
        )
        
        // w=0 表示方向向量：不受平移影响，只受 cameraPose 的旋转分量变换
        // 经头部旋转后世界方向：(−0.0659, 0.0166, −0.9977)，主要朝 -Z 前方飞出 ✅
        let directionHomogeneous = cameraPose * SIMD4<Double>(cameraSpacePoint, 0.0)
        let worldDirection = Vector3D(vector: normalize(directionHomogeneous.xyz))
        // 射线原点 = cameraPose.col3 = 相机在世界中的位置
        // log9: origin = (-0.0303, 0.8888, -0.1508) ← 左眼世界位置 ✅
        let worldOrigin = Transform(matrixDouble: cameraPose).translationPoint3D
        
        // ── 🔍 DEBUG LOG：射线构造全流程 ───────────────────────────────
        print("\n🎯 [CameraToWorld] eye=\(eye)")
        print("  ① 输入像素(左上角原点): (\(cameraPoint.x), \(cameraPoint.y))  分辨率: \(resolution.width)×\(resolution.height)")
        print("  ② Y轴翻转后: pixel_x=\(pixel_x)  pixel_y=\(resolution.height)-\(point.y)=\(pixel_y)")
        print("  ③ 内参: fx=\(fx)  fy=\(fy)  cx=\(cx)  cy=\(cy)")
        print("  ④ 相机空间方向(归一化平面, z=-1): (\(cameraSpacePoint.x), \(cameraSpacePoint.y), \(cameraSpacePoint.z))")
        print("     z=-1 确认相机朝 -Z 方向看")
        print("  ⑤ 世界射线原点: \(worldOrigin)")
        print("  ⑥ 世界射线方向(单位向量): \(worldDirection)")
        let backProjected = worldOrigin + 1.0 * worldDirection
        print("  🔄 验证(沿射线走 1m 后位置): (\(backProjected.x), \(backProjected.y), \(backProjected.z))  ←可用 WorldToCamera 反投验证")
        // ───────────────────────────────────────────────────────────────
        return Ray3D(origin: worldOrigin, direction: worldDirection)
    }
    
    // 从图片宽高计算cx和cy
    private func getCxCy(W: Double, H: Double) -> (cx: Double, cy: Double) {
        (cx: W / 2, cy: H / 2)
    }
    
    // 从 FOV（弧度）和图片高度计算fy
    private func fy(vfov: Double, height: Double) -> Double {
        (height * 0.5) / tan(vfov / 2.0)
    }
    
    // 从内参矩阵中提取焦距 (fx, fy) 和主点 (cx, cy)，焦距的单位是像素而不是毫米
    private func restoreIntrinsics(simpleIntrinsic: SingleEyeIntrinsic.SimpleCameraIntrinsic, resolution: Size2D) -> (fx: Double, fy: Double, cx: Double, cy: Double) {
        let (cx, cy) = getCxCy(W: resolution.width, H: resolution.height)
        let fy = fy(vfov: simpleIntrinsic.yfov_radians, height: resolution.height)
        // 像素是正方形
        let fx = fy
        return (fx: fx, fy: fy, cx: cx, cy: cy)
    }
}
