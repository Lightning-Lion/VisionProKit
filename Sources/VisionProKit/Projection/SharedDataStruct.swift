import os
import SwiftUI
import Spatial
import ARKit
import RealityKit

// MARK: - PerspectiveCameraData
/// 透视相机数据
/// 存储一次世界→相机投影所需的全部数据
/// 包括内参、左右眼相机姿态、分辨率
nonisolated
public struct PerspectiveCameraData: Equatable, Sendable {
    public var simpleIntrinsic: SingleEyeIntrinsic.SimpleCameraIntrinsic
    public var leftEyeCameraPose: Transform
    public var rightEyeCameraPose: Transform
    public var resolution: Size2D
    
    public init(simpleIntrinsic: SingleEyeIntrinsic.SimpleCameraIntrinsic, leftEyeCameraPose: Transform, rightEyeCameraPose: Transform, resolutionV1: Size2D) {
        self.simpleIntrinsic = simpleIntrinsic
        self.leftEyeCameraPose = leftEyeCameraPose
        self.rightEyeCameraPose = rightEyeCameraPose
        self.resolution = resolutionV1
    }
}

// MARK: - SingleEyeIntrinsic
/// 单眼内参处理器
/// 使用这一组内参，在游戏引擎中拍摄的画面就和Vision Pro摄像头画面一样
/// 支持针孔相机模型、透视投影、相同的FOV、宽高比和分辨率
nonisolated
public struct SingleEyeIntrinsic: Sendable {
    public struct SimpleCameraIntrinsic: Equatable, Sendable {
        public var yfov_radians: Double
        public var aspectRatio: Double
        public func yfov_deg() -> Double {
            return yfov_radians * (180.0 / .pi)
        }
        public init(yfov_radians: Double, aspectRatio: Double) {
            self.yfov_radians = yfov_radians
            self.aspectRatio = aspectRatio
        }
    }

    /// K 矩阵 → SimpleCameraIntrinsic（VFOV + 宽高比）压缩。
    ///
    /// 压缩是**完全无损**的，因为：
    ///   - `guard fx==fy`（像素正方形）保证焦距可从单一 VFOV 完整重建
    ///   - `guard cx==W/2, cy==H/2`（主点在中心）保证 cx/cy 可从分辨率直接重算
    ///
    /// log6.log 数值验证（分辨率 1920×1080）：
    ///   原始:  fx=fy=736.6339px  cx=960.0  cy=540.0
    ///   压缩:  VFOV=72.4876°  aspectRatio=16/9
    ///   重建:  fy = (1080/2) / tan(72.4876°/2) = 540 / tan(36.2438°) = 736.6339px  ✅
    ///   重建误差 = 0.00000000px（完全无损）
    public static func leftEyeSimpleIntrinsic(leftEyeIntrinsics: simd_double3x3, cameraImageSize: Size2D) throws -> SimpleCameraIntrinsic {
        let K = leftEyeIntrinsics

        // Apple K 矩阵使用转置约定，与标准 OpenCV 不同：
        //   Apple:  col0=(fx,0,cx), col1=(0,fy,cy), col2=(0,0,1)
        //   OpenCV: col0=(fx,0,0),  col1=(0,fy,0),  col2=(cx,cy,1)
        // 所以读取方式为 K.columns.0.z 而非 K.columns.2.x
        let fx: Double = K.columns.0.x  // log6: 736.6339px
        let fy: Double = K.columns.1.y  // log6: 736.6339px（==fx，像素正方形 ✅）
        let cx: Double = K.columns.0.z  // log6: 960.0 = 1920/2（主点在中心 ✅）
        let cy: Double = K.columns.1.z  // log6: 540.0 = 1080/2（主点在中心 ✅）

        let W: Double = 2 * cx
        let H: Double = 2 * cy
        
        guard fx == fy else {
            throw SimpleIntrinsicError.fxNotEqualfy("假设像素是正方形，fx应该等于fy。实际上fx不等于fy，像素不是正方形。")
        }
        
        guard W == cameraImageSize.width && H == cameraImageSize.height else {
            throw SimpleIntrinsicError.widthOrHeightNotMatch("假设主点在图像中心，计算出的宽高是\(W)×\(H)，但实际的宽高是\(cameraImageSize.debugDescription)，也就是主点不在图像中心。")
        }
        
        @inline(__always)
        func fovRad(size: Double, f: Double) -> Double {
            return 2.0 * atan((size * 0.5) / f)
        }

        let VFOV = fovRad(size: H, f: fy)
        // ── 🔍 DEBUG LOG：内参压缩过程 ──────────────────────────────────
        print("\n🔬 [内参压缩 K → SimpleCameraIntrinsic]")
        print("  步骤 1 — 从 K 矩阵提取（Apple转置约定）:")
        print("    fx=\(fx)  fy=\(fy)  cx=\(cx)  cy=\(cy)")
        print("    fx==fy？\(fx == fy)  （验证像素是正方形）")
        print("  步骤 2 — 反推图像尺寸 W=2*cx H=2*cy:")
        print("    W=\(W)  H=\(H)  (实际传入分辨率: \(cameraImageSize.width)×\(cameraImageSize.height))")
        print("    尺寸匹配？\(W == cameraImageSize.width && H == cameraImageSize.height)  （验证主点在图像中心）")
        print("  步骤 3 — 压缩为 VFOV:")
        print("    VFOV = 2*atan(H/2/fy) = 2*atan(\(H/2)/\(fy))")
        print("    VFOV = \(VFOV) rad = \(VFOV * 180 / .pi)°")
        print("    aspectRatio W/H = \(W/H)")
        print("  ⚠️ 压缩后仅保留 VFOV+宽高比，fx/fy/cx/cy 信息被丢弃，重建时假设主点在中心")
        // ────────────────────────────────────────────────────────────
        return .init(yfov_radians: VFOV, aspectRatio: W / H)
    }
    
    public enum SimpleIntrinsicError: LocalizedError {
        case fxNotEqualfy(String)
        case widthOrHeightNotMatch(String)
        public var errorDescription: String? {
            switch self {
            case .fxNotEqualfy(let detail):
                detail
            case .widthOrHeightNotMatch(let detail):
                detail
            }
        }
    }
}

// MARK: - Point2D
/// Double版本的CGPoint
nonisolated
public struct Point2D: Hashable, Equatable, Sendable, CustomDebugStringConvertible {
    public var x: Double
    public var y: Double
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    public var debugDescription: String {
        x.formatted() + ", " + y.formatted()
    }
    public func toCGPoint() -> CGPoint {
        CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

// MARK: - Size2D
/// Double版本的2D尺寸
nonisolated
public struct Size2D: Hashable, Equatable, Sendable, CustomDebugStringConvertible {
    public var width: Double
    public var height: Double
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    public init(simd2Double: SIMD2<Double>) {
        self.width = simd2Double.x
        self.height = simd2Double.y
    }
    public var debugDescription: String {
        width.formatted() + " × " + height.formatted()
    }
}

// MARK: - Device
/// 设备结构
nonisolated
public struct Device: Sendable {
    public var eye: Camera
    public var deviceTransform: Transform
    public init(eye: Camera, deviceTransform: Transform) {
        self.eye = eye
        self.deviceTransform = deviceTransform
    }
    public enum Camera: Sendable {
        case left
        case right
    }
}

// MARK: - ScreenPoseAndSize
/// 屏幕姿态和尺寸结果
public struct ScreenPoseAndSize: Sendable {
    public let pose: Transform
    public let size: Size2D
    public init(pose: Transform, size: Size2D) {
        self.pose = pose
        self.size = size
    }
}
