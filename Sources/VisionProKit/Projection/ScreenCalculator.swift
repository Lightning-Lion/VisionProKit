import os
import SwiftUI
import Spatial
import ARKit
import RealityKit

nonisolated
private let logger = Logger(subsystem: "com.visionprokit.screencalculator", category: "debug")

// MARK: - ScreenCalculator
/// 直接屏幕计算器
/// 根据相机内参和姿态，计算放置在指定距离处的屏幕姿态和尺寸
public actor ScreenCalculator {
    private let perspectiveCameraData: PerspectiveCameraData?
    private let intrinsic: SingleEyeIntrinsic.SimpleCameraIntrinsic

    /// 使用完整相机数据初始化，支持按眼位计算
    public init(perspectiveCameraData: PerspectiveCameraData) {
        self.perspectiveCameraData = perspectiveCameraData
        self.intrinsic = perspectiveCameraData.simpleIntrinsic
    }

    /// 仅使用内参初始化，调用者自行传入相机姿态
    public init(intrinsic: SingleEyeIntrinsic.SimpleCameraIntrinsic) {
        self.perspectiveCameraData = nil
        self.intrinsic = intrinsic
    }

    /// 按眼位计算屏幕姿态和尺寸（需以 perspectiveCameraData 初始化）
    public func calculateScreenPoseAndSize(eye: Device.Camera, distance: Double) -> (pose: Transform, size: Size2D) {
        guard let data = perspectiveCameraData else {
            fatalError("calculateScreenPoseAndSize(eye:distance:) requires initialization with PerspectiveCameraData")
        }
        let cameraTransform = Transform(matrixDouble: getCameraPose(for: eye, data: data))
        return calculateScreenPoseAndSize(cameraPose: cameraTransform, distance: distance)
    }

    /// 根据相机姿态和距离，计算屏幕的 pose 和 size
    public func calculateScreenPoseAndSize(
        cameraPose: Transform,
        distance: Double
    ) -> (pose: Transform, size: Size2D) {
        let cameraForward = cameraPose.matrixDouble.zAxis
        let cameraPosition = cameraPose.translationPoint3D.vector
        let screenCenter = cameraPosition + (-distance) * cameraForward

        let height = 2.0 * distance * tan(intrinsic.yfov_radians / 2.0)
        let width = height * intrinsic.aspectRatio
        let size = Size2D(width: width, height: height)

        var screenMatrix = cameraPose.matrixDouble
        screenMatrix.columns.3 = SIMD4<Double>(screenCenter.x, screenCenter.y, screenCenter.z, 1.0)
        let screenPose = Transform(matrixDouble: screenMatrix)

        return (pose: screenPose, size: size)
    }

    private func getCameraPose(for camera: Device.Camera, data: PerspectiveCameraData) -> simd_double4x4 {
        switch camera {
        case .left:  return data.leftEyeCameraPose.matrixDouble
        case .right: return data.rightEyeCameraPose.matrixDouble
        }
    }
}
