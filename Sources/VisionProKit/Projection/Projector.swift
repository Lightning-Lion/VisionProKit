import os
import SwiftUI
import Spatial
import RealityKit
import Combine

// MARK: - ThreeDTo2DProjector
/// 3D到2D投影器
/// 将3D取景框投影到2D四边形屏幕
/// 负责计算屏幕姿态和尺寸，以及将3D角点投影到2D像素坐标
@MainActor
@Observable
public class ThreeDTo2DProjector {
    public var camera: Device.Camera
    public var intrinsicsAndExtrinsics: GetIntrinsicsAndExtrinsics.IntrinsicsAndExtrinsics
    
    public init(camera: Device.Camera, intrinsicsAndExtrinsics: GetIntrinsicsAndExtrinsics.IntrinsicsAndExtrinsics) {
        self.camera = camera
        self.intrinsicsAndExtrinsics = intrinsicsAndExtrinsics
    }
    
    /// 同一个3D点，在左眼相机和右眼相机中的坐标是不同的，因此初始化类时需要传入var camera: Device.Camera
    /// 把3D点投影到2D像素坐标
    /// 我们允许fov外的点，因为如果图像有一个角不在画面内，我们也可以裁切部分，QuadrilateralCropper会判断
    /// 但如果3D点不在面前，会抛出
    public func to2DCornersPoint(
        cornersPose: ViewfinderOrnamentCornersPose,
        head: Transform
    ) async throws -> Viewfinder2DCornersPose {
        let perspectiveCameraData = try await buildupPerspectiveData(head: head, intrinsicsAndExtrinsics: intrinsicsAndExtrinsics)
        let worldToCamera = WorldToCamera(perspectiveCameraData: perspectiveCameraData)
        let topLeft2D = try worldToCamera.worldPointToCameraPixel(worldPoint: cornersPose.topLeft, eye: camera)
        let topRight2D = try worldToCamera.worldPointToCameraPixel(worldPoint: cornersPose.topRight, eye: camera)
        let bottomLeft2D = try worldToCamera.worldPointToCameraPixel(worldPoint: cornersPose.bottomLeft, eye: camera)
        let bottomRight2D = try worldToCamera.worldPointToCameraPixel(worldPoint: cornersPose.bottomRight, eye: camera)
        return Viewfinder2DCornersPose(
            topLeft: topLeft2D,
            topRight: topRight2D,
            bottomLeft: bottomLeft2D,
            bottomRight: bottomRight2D
        )
    }
    
    /// 直接计算屏幕姿态和尺寸（EyeCover使用）
    public func getScreenDirect(
        head: Transform,
        distance: Double
    ) async throws -> (pose: Transform, size: Size2D) {
        let perspectiveCameraData = try await buildupPerspectiveData(head: head, intrinsicsAndExtrinsics: intrinsicsAndExtrinsics)
        let calculator = ScreenCalculator(perspectiveCameraData: perspectiveCameraData)
        let result = await calculator.calculateScreenPoseAndSize(eye: camera, distance: distance)
        return result
    }
    
    /// 从传入的原始数据构造实用的PerspectiveCameraData
    public func buildupPerspectiveData(
        head: Transform,
        intrinsicsAndExtrinsics: GetIntrinsicsAndExtrinsics.IntrinsicsAndExtrinsics
    ) async throws -> PerspectiveCameraData {
        let currentFrameInner = intrinsicsAndExtrinsics
        let resolution = Size2D(width: currentFrameInner.resolution.width, height: currentFrameInner.resolution.height)
        let perspectiveCameraData = try await ProcessCameraFrameIntrinsicsAndExtrinsics().processCameraFrameIntrinsicsAndExtrinsics(
            deviceTransform: head,
            leftEyeIntrinsics: currentFrameInner.leftEyeIntrinsics,
            rightEyeIntrinsics: currentFrameInner.rightEyeIntrinsics,
            leftEyeExtrinsics: currentFrameInner.leftEyeExtrinsics,
            rightEyeExtrinsics: currentFrameInner.rightEyeExtrinsics,
            resolution: resolution
        )
        return perspectiveCameraData
    }
    
    // MARK: - 3D角点数据结构
    /// 取景框3D角点
    public struct ViewfinderOrnamentCornersPose: Sendable {
        public var topLeft: Point3D
        public var topRight: Point3D
        public var bottomLeft: Point3D
        public var bottomRight: Point3D
        public init(topLeft: Point3D, topRight: Point3D, bottomLeft: Point3D, bottomRight: Point3D) {
            self.topLeft = topLeft
            self.topRight = topRight
            self.bottomLeft = bottomLeft
            self.bottomRight = bottomRight
        }
    }
    
    // MARK: - 2D角点数据结构
    /// 取景框2D角点（复用QuadrilateralCropper中的定义）
    public typealias Viewfinder2DCornersPose = QuadrilateralCropper.Viewfinder2DCornersPose
}

// MARK: - SingleEyeExtrinsic
/// 单眼外参处理器
/// 将 ARKit 提供的外参（View 矩阵）转换为 RealityKit 局部坐标的相机 Pose 矩阵
nonisolated
public struct SingleEyeExtrinsic: Sendable {
    /// ARKit 外参（View 矩阵）→ RealityKit 相机 Pose 矩阵。
    ///
    /// ## 为什么 ARKit extrinsics 是 View 矩阵，不是 Pose 矩阵？
    ///
    /// Pose 矩阵（相机→世界）形式：  P = [R | t_cam]  其中 P.col3 = t_cam = 相机真实位置
    /// View 矩阵（世界→相机）是 Pose 的逆：  E = P⁻¹ = [Rᵀ | −Rᵀ·t_cam]
    ///     ∴ E.col3 = −Rᵀ·t_cam ≠ 相机位置
    ///
    /// 错误用法（把 col3 直接当位置）会导致 IPD 偏差：
    ///   左眼 E.col3 = ( 0.02437, -0.02011, -0.05793)
    ///   右眼 E.col3 = (-0.02452, -0.02033, -0.05774)
    ///   ‖左−右‖ ≈ 0.0489m = 4.89cm  ❌（人眼 IPD 应为 ~6.3cm）
    ///
    /// ## 两步变换链
    ///
    /// ARKit 用 OpenCV 坐标系（+Y向下，+Z向前），RealityKit 用右手系（+Y向上，+Z向后）
    /// 两者 Y、Z 轴方向相反，差一个绕 X 轴旋转 π 的变换
    ///
    ///   R_x(π) = [1,  0,  0]
    ///              [0, -1,  0]
    ///              [0,  0, -1]
    ///
    ///   ARKit E（View, OpenCV）
    ///     ──① R_x(π)·E ──▶  rotated（View, RealityKit, Y/Z 已翻转）
    ///     ──② .inverse ─▶  inversed（Pose, Camera_RK → Device_Local）
    ///
    /// ## log6.log 左眼 col3 三阶段数值变化
    ///
    ///   阶段1  E.col3（原始）         = ( 0.02437, -0.02011, -0.05793)  ← −Rᵀ·t，非位置
    ///   阶段2  R_x(π)·E.col3         = ( 0.02437, +0.02011, +0.05793)  ← Y/Z 取反，仍是 View 的 col3
    ///   阶段3  Pose.col3（求逆后）      = (-0.03163, -0.02517, -0.05215)  ← 相机在设备局部真实位置 ✅
    ///           右眼 Pose.col3         = ( 0.03202, -0.02546, -0.05172)
    ///
    /// ## IPD 数值验证
    ///
    ///   左眼位置 t_L = (-0.03163, -0.02517, -0.05215)
    ///   右眼位置 t_R = ( 0.03202, -0.02546, -0.05172)
    ///   ‖t_L − t_R‖ = √(0.06365² + 0.00029² + 0.00043²) ≈ 0.0637m = 6.37cm  ✅
    ///
    ///   对比错误假设（col3 直接当位置）：‖E_L.col3 − E_R.col3‖ ≈ 4.89cm  ❌
    ///   人眼 IPD 正常范围 5~8cm，6.37cm 落在范围内，验证变换链完全正确 ✅
    public static func getViewTransform(from extrinsic: simd_double4x4) throws -> Transform {
        let rotation = simd_quatd(angle: .pi, axis: [1, 0, 0])
        let rotationMatrix = Transform(rotationDouble: rotation).matrixDouble
        
        let rotated = rotationMatrix * extrinsic
        let inversed = rotated.inverse
        let cameraViewTransform = Transform(matrixDouble: inversed)
        // ── 🔍 DEBUG LOG：外参变换链（核心疑惑：绕X轴转π的来源）───────
        let fc = { (v: Double) in String(format: "% .5f", v) }
        let logM: (String, simd_double4x4) -> Void = { label, m in
            print("  \(label):")
            let r = m.columns
            print("    |\(fc(r.0.x))  \(fc(r.1.x))  \(fc(r.2.x))  \(fc(r.3.x))|  ←行0")
            print("    |\(fc(r.0.y))  \(fc(r.1.y))  \(fc(r.2.y))  \(fc(r.3.y))|  ←行1")
            print("    |\(fc(r.0.z))  \(fc(r.1.z))  \(fc(r.2.z))  \(fc(r.3.z))|  ←行2")
            print("    |\(fc(r.0.w))  \(fc(r.1.w))  \(fc(r.2.w))  \(fc(r.3.w))|  ←行3")
        }
        print("\n🔄 [getViewTransform] 外参变换链")
        print("  E = View矩阵(Device→Camera_OpenCV)  rotated = R_x(π)·E = View矩阵(Device→Camera_RK)  inversed = Pose矩阵(Camera_RK→Device)")
        logM("① ARKit 原始 E（View矩阵: Device_Local → Camera_OpenCV）", extrinsic)
        logM("② R_x(π)·E = rotated（View矩阵: Device_Local → Camera_RK, Y/Z已翻转）", rotated)
        logM("③ rotated⁻¹ = inversed（Pose矩阵: Camera_RK → Device_Local）", inversed)
        print("  col2(Z轴) 原=\(extrinsic.columns.2.xyz) → 旋转后=\(rotated.columns.2.xyz) → 求逆后=\(inversed.columns.2.xyz)")
        print("  col3       原=\(extrinsic.columns.3.xyz) → 旋转后=\(rotated.columns.3.xyz) → 求逆后=\(inversed.columns.3.xyz)  ← 这才是相机在设备局部的真实位置")
        // ──────────────────────────────────────────────────────
        // 下游处理的时候（比如Kabsch算法设计用于找到最优的刚体变换）
        // 常常假设相机外参只包含旋转和平移，我们要验证这一点。
        
        // 验证 det(R) == 1
        let epsilon: Float = 1e-6
        guard abs(simd_determinant(cameraViewTransform.matrix) - 1) < epsilon else {
            throw GetViewTransformError.notRigidTransformation("假设是正交变换（旋转+平移），行列式理应为 1，事实上行列式不等于 1，所以矩阵包含缩放或投影。")
        }
        let tolerance: Float = 1e-6
        guard abs(cameraViewTransform.scale.x - 1) < tolerance &&
                abs(cameraViewTransform.scale.y - 1) < tolerance &&
                abs(cameraViewTransform.scale.z - 1) < tolerance else {
            throw GetViewTransformError.notRigidTransformation("不是刚性变换，可能带有缩放。")
        }
        // 验证是否只包含旋转和平移，没有缩放、非均匀缩放或其他仿射变换成分。
        guard isEqual(cameraViewTransform, Transform(rotation: cameraViewTransform.rotation, translation: cameraViewTransform.translation), tolerance: 1e-6) else {
            throw GetViewTransformError.notRigidTransformation("不是刚性变换，可能带有缩放和剪切。")
        }
        
        return Transform(matrixDouble: inversed)
    }
    
    private static func isEqual(_ origin: Transform, _ target: Transform, tolerance: Float) -> Bool {
        let translationEqual = origin.translation == target.translation
        let rotationEqual = origin.rotation == target.rotation
        let scaleEqual = all(abs(origin.scale - target.scale) .<= SIMD3<Float>(repeating: tolerance))
        return translationEqual && rotationEqual && scaleEqual
    }
    
    public enum GetViewTransformError: LocalizedError {
        case notRigidTransformation(String)
        public var errorDescription: String? {
            switch self {
            case .notRigidTransformation(let detail):
                detail
            }
        }
    }
}

// MARK: - ProcessCameraFrameIntrinsicsAndExtrinsics
/// 相机帧内外参处理器
/// 从Sample给出的内参外参，计算出方便使用的内参外参
/// 因为Sample给出的外参是局部坐标的，而不是全局坐标的，不符合一般渲染引擎外参的习惯
public actor ProcessCameraFrameIntrinsicsAndExtrinsics {
    public init() {}
    
    public func processCameraFrameIntrinsicsAndExtrinsics(
        deviceTransform: Transform,
        leftEyeIntrinsics: simd_float3x3,
        rightEyeIntrinsics: simd_float3x3,
        leftEyeExtrinsics: simd_float4x4,
        rightEyeExtrinsics: simd_float4x4,
        resolution: Size2D
    ) throws -> PerspectiveCameraData {
        // 以Vision Pro的硬件设计，左右相机的内参应该是一样的
        guard leftEyeIntrinsics == rightEyeIntrinsics else {
            throw ProcessCameraFrameIntrinsicsAndExtrinsicsError.designForVisionProOnly
        }
        let simpleIntrinsic = try SingleEyeIntrinsic.leftEyeSimpleIntrinsic(leftEyeIntrinsics: convertToDouble3x3(from: leftEyeIntrinsics), cameraImageSize: resolution)
       
        let leftEyeCameraViewTransform = try SingleEyeExtrinsic.getViewTransform(from: simd_double4x4(leftEyeExtrinsics))
        // cameraPose（世界坐标）= deviceTransform（头部 World）× viewTransform（Camera_RK → Device_Local）
        // log6.log 实测：
        //   头部 deviceTransform.translation = (-0.0064,  1.2214, -0.0915)
        //   左眼 viewTransform.translation  = (-0.0316, -0.0252, -0.0522)  ← Pose.col3
        //   左眼 cameraPose.translation     = (-0.0403,  1.2054, -0.1457)  ← 左眼在世界的位置
        //   右眼 cameraPose.translation     = ( 0.0233,  1.2039, -0.1477)  ← 右眼在世界的位置
        //   IPD = ‖左眼 − 右眼‖ = 0.0637m ✅（人眼双目约 0.063m）
        // 计算左眼在世界中的pose
        let leftEyeCameraPose = Transform(matrixDouble: deviceTransform.matrixDouble * leftEyeCameraViewTransform.matrixDouble)
        
        let rightEyeCameraViewTransform = try SingleEyeExtrinsic.getViewTransform(from: simd_double4x4(rightEyeExtrinsics))
        // 计算右眼在世界中的pose
        let rightEyeCameraPose = Transform(matrixDouble: deviceTransform.matrixDouble * rightEyeCameraViewTransform.matrixDouble)
        
        // ── 🔍 DEBUG LOG：外参合成结果────────────────────────────────────
        print("\n🌍 [外参合成] processCameraFrameIntrinsicsAndExtrinsics")
        print("  deviceTransform(头部) 平移: \(deviceTransform.translation)")
        print("  左眼 ViewTransform 平移: \(leftEyeCameraViewTransform.translation)  (getViewTransform返回值)")
        print("  右眼 ViewTransform 平移: \(rightEyeCameraViewTransform.translation)")
        print("  左眼 ViewTransform 旋转: \(leftEyeCameraViewTransform.rotation)")
        print("  右眼 ViewTransform 旋转: \(rightEyeCameraViewTransform.rotation)")
        print("  ─ 合成后（世界坐标 cameraPose = deviceTransform * viewTransform）─")
        print("  左眼 cameraPose 平移: \(leftEyeCameraPose.translation)")
        print("  右眼 cameraPose 平移: \(rightEyeCameraPose.translation)")
        let ipdVec = SIMD3<Double>(leftEyeCameraPose.translation) - SIMD3<Double>(rightEyeCameraPose.translation)
        let ipd = simd_length(ipdVec)
        print("  两眼间距(IPD): \(String(format: "%.4f", ipd)) m  (正常双目约 0.063 m)")
        print("  ✅ 如果IPD在 0.05~0.08m 范围内，外参合成逻辑基本正确")
        // ──────────────────────────────────────────────────────────
        return PerspectiveCameraData(simpleIntrinsic: simpleIntrinsic, leftEyeCameraPose: leftEyeCameraPose, rightEyeCameraPose: rightEyeCameraPose, resolutionV1: resolution)
    }
    
    private func convertToDouble3x3(from floatMatrix: simd_float3x3) -> simd_double3x3 {
        return simd_double3x3(
            columns: (
                SIMD3<Double>(Double(floatMatrix.columns.0.x), Double(floatMatrix.columns.0.y), Double(floatMatrix.columns.0.z)),
                SIMD3<Double>(Double(floatMatrix.columns.1.x), Double(floatMatrix.columns.1.y), Double(floatMatrix.columns.1.z)),
                SIMD3<Double>(Double(floatMatrix.columns.2.x), Double(floatMatrix.columns.2.y), Double(floatMatrix.columns.2.z))
            )
        )
    }
    
    public enum ProcessCameraFrameIntrinsicsAndExtrinsicsError: LocalizedError {
        case designForVisionProOnly
        public var errorDescription: String? {
            switch self {
            case .designForVisionProOnly:
                "本App仅为Vision Pro设计"
            }
        }
    }
}
