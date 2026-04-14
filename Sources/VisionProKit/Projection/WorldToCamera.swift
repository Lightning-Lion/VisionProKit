import os
import SwiftUI
import Spatial
import ARKit
import RealityKit

// MARK: - WorldToCamera
/// 世界到相机坐标转换器
/// 将世界坐标系中的3D点投影到相机图像平面
public class WorldToCamera {
    // 传入包括内参、外参、分辨率的PerspectiveCameraData
    private var perspectiveCameraData: PerspectiveCameraData
    
    public init(perspectiveCameraData: PerspectiveCameraData) {
        self.perspectiveCameraData = perspectiveCameraData
    }
    
    /// 将世界坐标系中的3D点投影到相机图像平面（针孔相机模型）。
    ///
    /// 投影公式，五步流程（log6.log 左眼角点1 实测验证）：
    ///
    ///   ① 将世界点变换到相机地址空间：
    ///       世界点: (-0.19359,  1.31431, -0.50657)
    ///       cameraPose¹: col3=(-0.04032,  1.20536, -0.14572) ← 相机在世界的位置
    ///       相机空间: (-0.09213,  0.08289, -0.38758)  z=-0.388<0 ✅（相机朝 -Z 看）
    ///
    ///   ② 透视投影到归一化平面：
    ///       normalizedX = -0.09213 / 0.38758 = -0.2377
    ///       normalizedY =  0.08289 / 0.38758 =  0.2139
    ///
    ///   ③ 应用内参（fx=fy=736.6339px  cx=960  cy=540）：
    ///       pixelX = -0.2377 × 736.6339 + 960 = 784.90
    ///       pixelY =  0.2139 × 736.6339 + 540 = 697.55
    ///
    ///   ④ Y轴翻转（3D +Y向上 → 图像 +Y向下）：
    ///       imageY = 1080 - 697.55 = 382.45
    ///       最终像素: (784.90, 382.45) ✅ 在画面 [0~1920, 0~1080] 内
    ///
    /// 四角全在画面内（log6.log 左眼）：
    ///   左上(784.9, 382.5)  右上(1646.1, 361.1)  左下(807.9, 978.1)  右下(1602.3, 998.6) ✅
    /// - Parameters:
    ///   - worldPoint: 世界坐标系中的3D点
    ///   - eye: 左眼或右眼相机
    /// - Returns: 2D像素坐标（左上角为原点，Y向下）
    public func worldPointToCameraPixel(
        worldPoint: Point3D,
        eye: Device.Camera
    ) throws -> Point2D {
        // 获取相机参数
        let cameraPose = getCameraPose(for: eye)
        let resolution = perspectiveCameraData.resolution
        // 从内参矩阵中提取焦距 (fx, fy) 和主点 (cx, cy)，焦距的单位是像素而不是毫米
        let (fx, fy, cx, cy) = GetIntrinsics().restoreIntrinsics(simpleIntrinsic: perspectiveCameraData.simpleIntrinsic, resolution: resolution)
        
        // 将世界点转换到相机坐标系
        // 把局部的方向向量转换为世界的方向向量，计算时将齐次坐标的 w 分量设为 0。
        let worldPointHomogeneous = SIMD4<Double>(worldPoint.x, worldPoint.y, worldPoint.z, 1.0)
        // 计算相机变换矩阵的逆（世界→相机）
        let cameraViewMatrix = cameraPose.inverse
        // 转换到相机空间
        let cameraSpaceHomogeneous = cameraViewMatrix * worldPointHomogeneous
        let cameraSpacePoint = cameraSpaceHomogeneous.xyz
        
        // 检查点是否在相机前方
        if cameraSpacePoint.z >= 0 {
            throw WorldToCameraError.pointNotInFront
        }
        
        // 透视投影到图像平面
        let normalizedX = cameraSpacePoint.x / (-cameraSpacePoint.z)
        let normalizedY = cameraSpacePoint.y / (-cameraSpacePoint.z)
        
        let pixelX = normalizedX * fx + cx
        let pixelY = normalizedY * fy + cy
        
        // Y轴翻转（3D Y向上 → 图像Y向下）
        let imageY = resolution.height - pixelY
        
        // ── 🔍 DEBUG LOG：投影全流程 ────────────────────────────────
        print("\n🗺️ [WorldToCamera] eye=\(eye)")
        print("  ① 输入世界点: (\(worldPoint.x), \(worldPoint.y), \(worldPoint.z))")
        print("  ② 相机在世界中的位置: col3=\(cameraPose.columns.3.xyz)")
        print("  ③ 相机空间点 cameraSpacePoint: (\(cameraSpacePoint.x), \(cameraSpacePoint.y), \(cameraSpacePoint.z))")
        print("     z=\(cameraSpacePoint.z)  ← z<0 表示在相机前方（相机朝 -Z 看）")
        print("  ④ 内参: fx=\(fx)  fy=\(fy)  cx=\(cx)  cy=\(cy)")
        print("  ⑤ 归一化坐标: normalizedX=\(normalizedX)  normalizedY=\(normalizedY)")
        print("  ⑥ 像素坐标(Y翻转前): (\(pixelX), \(pixelY))")
        print("  ⑦ 最终像素(Y翻转后, 左上角原点): (\(pixelX), \(imageY))")
        print("     应在画面内？ x∘0~\(resolution.width): \(pixelX >= 0 && pixelX <= resolution.width)  y∘0~\(resolution.height): \(imageY >= 0 && imageY <= resolution.height)")
        // ───────────────────────────────────────────────────────────────
        return Point2D(x: pixelX, y: imageY)
    }
    
    // 获取相机的世界姿态
    private func getCameraPose(for camera: Device.Camera) -> simd_double4x4 {
        switch camera {
        case .left:
            return perspectiveCameraData.leftEyeCameraPose.matrixDouble
        case .right:
            return perspectiveCameraData.rightEyeCameraPose.matrixDouble
        }
    }
    
    public enum WorldToCameraError: LocalizedError {
        case pointNotInFront
        public var errorDescription: String? {
            switch self {
            case .pointNotInFront:
                "点在相机后方或平面上，不可见"
            }
        }
    }
    
    // MARK: - GetIntrinsics
    /// 内参计算器
    /// 从内参矩阵中提取焦距和主点等参数
    public class GetIntrinsics {
        public init() {}
        
        // 从图片像素宽高计算cx和cy
        public func getCxCy(W: Double, H: Double) -> (cx: Double, cy: Double) {
            (cx: W / 2, cy: H / 2)
        }
        
        // 从 FOV（弧度）和图片高度计算fy
        public func fy(vfov: Double, height: Double) -> Double {
            (height * 0.5) / tan(vfov / 2.0)
        }
     
        public func restoreIntrinsics(simpleIntrinsic: SingleEyeIntrinsic.SimpleCameraIntrinsic, resolution: Size2D) -> (fx: Double, fy: Double, cx: Double, cy: Double) {
            let (cx, cy) = getCxCy(W: resolution.width, H: resolution.height)
            let fy = fy(vfov: simpleIntrinsic.yfov_radians, height: resolution.height)
            // 像素是正方形
            let fx = fy
            return (fx: fx, fy: fy, cx: cx, cy: cy)
        }
    }
}
