import os
import SwiftUI
import ARKit

// MARK: - GetIntrinsicsAndExtrinsics
/// 相机内外参获取器
/// 在ImmersiveSpace启动时获取相机内参和外参
/// 这些参数在整个CameraFrameProvider.CameraFrameUpdates内是固定的
/// 切换不同的摄像头参数会有变化，因为不同的分辨率、不同的纵横比、不同的视场角
@MainActor
@Observable
public class GetIntrinsicsAndExtrinsics {
    private var arkitSession: ARKitSession? = nil
    private let worldTracking: WorldTrackingProvider = WorldTrackingProvider()
    private var cameraFrameProvider: CameraFrameProvider? = nil
    
    public init() {}
    
    public func getIntrinsicsAndExtrinsics() async throws -> IntrinsicsAndExtrinsics {
        let arkitSession = ARKitSession()
        let authorizationStatus = await arkitSession.requestAuthorization(for: [.cameraAccess])
        
        guard authorizationStatus[.cameraAccess] == .allowed else {
            throw RunCameraFrameProviderError()
        }
        
        let cameraFrameProvider = CameraFrameProvider()
        try await arkitSession.run([worldTracking, cameraFrameProvider])
        self.arkitSession = arkitSession
        self.cameraFrameProvider = cameraFrameProvider
        
        let desiredFormat = CameraWithHead.getCameraVideoFormat()
        
        guard let desiredFormat,
              let cameraFrameUpdates = cameraFrameProvider.cameraFrameUpdates(for: desiredFormat) else {
            throw ObserveCameraFrameUpdates()
        }
        
        let resolution: CGSize = desiredFormat.frameSize
        
        for await cameraFrame in cameraFrameUpdates {
            guard let leftEyeSample = cameraFrame.sample(for: .left), let rightEyeSample = cameraFrame.sample(for: .right) else {
                throw ObserveCameraFrameUpdates()
            }
            let leftEyeIntrinsics = leftEyeSample.parameters.intrinsics
            let rightEyeIntrinsics = rightEyeSample.parameters.intrinsics
            let leftEyeExtrinsics = leftEyeSample.parameters.extrinsics
            let rightEyeExtrinsics = rightEyeSample.parameters.extrinsics
            // ── 🔍 DEBUG LOG：ARKit 原始内参外参 ──────────────────────────
            let logK: (String, simd_float3x3) -> Void = { label, K in
                // Apple 的 K 矩阵是转置约定：cx/cy 存在第三列而不是第三行
                // column0=(fx,0,0), column1=(0,fy,0), column2=(cx,cy,1)
                // 所以 cx = K.columns.2.x，cy = K.columns.2.y
                // 但 ARKit 实际上是：column0=(fx,0,cx), column1=(0,fy,cy), column2=(0,0,1)
                // 即 cx = K.columns.0.z，cy = K.columns.1.z  —— 见 SharedDataStruct.swift
                print("  📐 \(label) K矩阵原始列向量（Apple转置约定）:")
                print("    col0: (\(K.columns.0.x), \(K.columns.0.y), \(K.columns.0.z))  ← (fx, 0, cx)")
                print("    col1: (\(K.columns.1.x), \(K.columns.1.y), \(K.columns.1.z))  ← (0, fy, cy)")
                print("    col2: (\(K.columns.2.x), \(K.columns.2.y), \(K.columns.2.z))  ← (0, 0, 1)")
                print("    → fx=\(K.columns.0.x)  fy=\(K.columns.1.y)  cx=\(K.columns.0.z)  cy=\(K.columns.1.z)")
            }
            let logE: (String, simd_float4x4) -> Void = { label, E in
                let f = { (v: Float) in String(format: "% .5f", v) }
                // E 是 View 矩阵（Device_Local → Camera_OpenCV）
                // col3 ≠ 相机位置，而是 -R^T·t_cam（视图矩阵的平移分量）
                // 真实相机位置 = -R_cam·col3，其中 R_cam = rotBlock(E)^T
                // 验证依据：View 假设下两相机 IPD≈6.37cm（✅），Pose 假设下≈4.89cm（❌）
                print("  📷 \(label) extrinsics（View矩阵: Device_Local → Camera_OpenCV）:")
                print("    col0: (\(f(E.columns.0.x)), \(f(E.columns.0.y)), \(f(E.columns.0.z)), \(f(E.columns.0.w)))")
                print("    col1: (\(f(E.columns.1.x)), \(f(E.columns.1.y)), \(f(E.columns.1.z)), \(f(E.columns.1.w)))")
                print("    col2: (\(f(E.columns.2.x)), \(f(E.columns.2.y)), \(f(E.columns.2.z)), \(f(E.columns.2.w)))")
                print("    col3(-R^T·t): (\(f(E.columns.3.x)), \(f(E.columns.3.y)), \(f(E.columns.3.z)), \(f(E.columns.3.w)))  ← 非相机位置")
            }
            print("\n╔═ [ARKit 原始数据] 分辨率: \(resolution.width)×\(resolution.height) ══════════════╗")
            logK("左眼", leftEyeIntrinsics)
            logK("右眼", rightEyeIntrinsics)
            print("  左眼==右眼内参？\(leftEyeIntrinsics == rightEyeIntrinsics)")
            logE("左眼", leftEyeExtrinsics)
            logE("右眼", rightEyeExtrinsics)
            print("╚════════════════════════════════════════════════════════════╝")
            // ──────────────────────────────────────────────────────────────
            let intrinsicsAndExtrinsics = IntrinsicsAndExtrinsics(
                leftEyeIntrinsics: leftEyeIntrinsics,
                rightEyeIntrinsics: rightEyeIntrinsics,
                leftEyeExtrinsics: leftEyeExtrinsics,
                rightEyeExtrinsics: rightEyeExtrinsics,
                resolution: resolution
            )
            return intrinsicsAndExtrinsics
        }
        throw GetIntrinsicsAndExtrinsicsError.noSampleProvided
    }
    
    // MARK: - IntrinsicsAndExtrinsics
    /// 内外参数据结构
    ///
    /// 存储 ARKit 提供的原始内参和外参，在一次会话内固定不变。
    ///
    /// log6.log 实测摘要（分辨率 1920×1080）：
    ///   内参: fx=fy=736.6339px  cx=960  cy=540（左右眼相同 ✅）
    ///   外参 = View 矩阵（Device_Local → Camera_OpenCV），有别于 Pose 矩阵
    ///   左眼 View.col3 = ( 0.02437, -0.02011, -0.05793)  ← −Rᵀ·t，非相机位置
    ///   右眼 View.col3 = (-0.02452, -0.02033, -0.05774)  ← −Rᵀ·t，非相机位置
    ///   真实相机位置需经 getViewTransform 求逆后从 Pose.col3 获取
    public struct IntrinsicsAndExtrinsics: Sendable {
        public var leftEyeIntrinsics: simd_float3x3
        public var rightEyeIntrinsics: simd_float3x3
        public var leftEyeExtrinsics: simd_float4x4
        public var rightEyeExtrinsics: simd_float4x4
        public var resolution: CGSize
        public init(leftEyeIntrinsics: simd_float3x3, rightEyeIntrinsics: simd_float3x3, leftEyeExtrinsics: simd_float4x4, rightEyeExtrinsics: simd_float4x4, resolution: CGSize) {
            self.leftEyeIntrinsics = leftEyeIntrinsics
            self.rightEyeIntrinsics = rightEyeIntrinsics
            self.leftEyeExtrinsics = leftEyeExtrinsics
            self.rightEyeExtrinsics = rightEyeExtrinsics
            self.resolution = resolution
        }
    }
    
    public struct RunCameraFrameProviderError: LocalizedError {
        public var errorDescription: String? {
            #if targetEnvironment(simulator)
            "请在真机上运行本项目"
            #else
            "权限未申请，导致authorizationStatus[.cameraAccess] != .allowed"
            #endif
        }
    }
    
    public struct ObserveCameraFrameUpdates: LocalizedError {
        public var errorDescription: String? {
            "cameraFrameProvider.cameraFrameUpdates() return nil"
        }
    }
    
    public enum GetIntrinsicsAndExtrinsicsError: LocalizedError {
        case noSampleProvided
        public var errorDescription: String? {
            switch self {
            case .noSampleProvided:
                "没有得到样本"
            }
        }
    }
}
