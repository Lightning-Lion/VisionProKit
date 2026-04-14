import os
import Spatial
import RealityKit
import simd
import Foundation

// MARK: - ScreenDistanceOptimizer
/// 屏幕距离优化器
/// 使用二分搜索算法找到使左右眼屏幕不相交的最小右眼距离
public actor ScreenDistanceOptimizer {
    
    /// 默认屏幕距离（米）- 左眼固定距离和右眼搜索下界
    public static let defaultScreenDistance: Double = 1
    /// 默认搜索范围上限相对于下限的倍数
    /// 注意：此倍数只影响阶段1（指数扩展）的初始上限，算法会自动扩展直到找到不相交点
    /// 较大的倍数可减少阶段1的检查次数，但不会限制最终输出的临界值
    public static let defaultHighMultiplier: Double = 1.67
    
    public struct OptimizationResult: Sendable {
        public let minDistance: Double
        public let iterationCount: Int
        public let finalCheck: ScreenIntersectionChecker.IntersectionResult
    }
    
    /// 二分搜索找到使屏幕不相交的最小右眼距离
    /// - Parameters:
    ///   - leftScreen: 左眼屏幕数据（已固定）
    ///   - rightCameraPose: 右眼相机姿态
    ///   - intrinsic: 相机内参（左右眼相同）
    ///   - low: 搜索下界（默认defaultScreenDistance）
    ///   - high: 搜索上界（默认defaultScreenDistance * defaultHighMultiplier）
    ///   - precision: 精度要求（默认0.001）
    /// - Returns: 优化结果
 
    public static func findMinDistanceSmart(
        leftScreen: ScreenIntersectionChecker.ScreenData,
        rightCameraPose: Transform,
        intrinsic: SingleEyeIntrinsic.SimpleCameraIntrinsic,
        startLow: Double = defaultScreenDistance,
        maxHigh: Double = 1000.0
    ) async -> OptimizationResult? {
        var low = startLow
        var high = startLow
        var step = 1.0
        var totalChecks = 0
        
        var inter = await checkIntersection(distance: low, leftScreen: leftScreen, rightCameraPose: rightCameraPose, intrinsic: intrinsic, debug: false)
        totalChecks += 1
        
        if !inter.intersects {
            return OptimizationResult(minDistance: low, iterationCount: 0, finalCheck: inter)
        }
        
        while high <= maxHigh {
            high = low + step
            inter = await checkIntersection(distance: high, leftScreen: leftScreen, rightCameraPose: rightCameraPose, intrinsic: intrinsic)
            totalChecks += 1
            if !inter.intersects { break }
            step *= 2
        }
        
        if inter.intersects { return nil }
        
        var iteration = 0
        let precision = 1e-8
        
        while high - low > precision {
            let mid = (low + high) / 2.0
            inter = await checkIntersection(distance: mid, leftScreen: leftScreen, rightCameraPose: rightCameraPose, intrinsic: intrinsic)
            iteration += 1
            if inter.intersects { low = mid } else { high = mid }
        }
        
        let result = high
        let totalIterations = totalChecks + iteration
        let finalCheck = await checkIntersection(distance: result, leftScreen: leftScreen, rightCameraPose: rightCameraPose, intrinsic: intrinsic)
        return OptimizationResult(minDistance: result, iterationCount: totalIterations, finalCheck: finalCheck)
    }
    
    
    private static func checkIntersection(
        distance: Double,
        leftScreen: ScreenIntersectionChecker.ScreenData,
        rightCameraPose: Transform,
        intrinsic: SingleEyeIntrinsic.SimpleCameraIntrinsic,
        debug: Bool = false
    ) async -> ScreenIntersectionChecker.IntersectionResult {
        let rightScreen = await calculateRightScreen(distance: distance, cameraPose: rightCameraPose, intrinsic: intrinsic)
        return ScreenIntersectionChecker.checkIntersection(screen1: leftScreen, screen2: rightScreen, debug: debug)
    }

    private static func calculateRightScreen(
        distance: Double,
        cameraPose: Transform,
        intrinsic: SingleEyeIntrinsic.SimpleCameraIntrinsic
    ) async -> ScreenIntersectionChecker.ScreenData {
        let calculator = ScreenCalculator(intrinsic: intrinsic)
        let (screenPose, screenSize) = await calculator.calculateScreenPoseAndSize(
            cameraPose: cameraPose,
            distance: distance
        )
        return ScreenIntersectionChecker.ScreenData(pose: screenPose, size: screenSize)
    }
}

// MARK: - ThreeDTo2DProjector 扩展
public extension ThreeDTo2DProjector {
    // 调用ScreenDistanceOptimizer
    func getOptimizedRightScreenDistance(
        head: Transform,
        leftScreenPose: Transform,
        leftScreenSize: Size2D,
    ) async throws -> Double {
        let perspectiveCameraData = try await buildupPerspectiveData(head: head, intrinsicsAndExtrinsics: intrinsicsAndExtrinsics)
        let leftScreen = ScreenIntersectionChecker.ScreenData(pose: leftScreenPose, size: leftScreenSize)
        
        if let result = await ScreenDistanceOptimizer.findMinDistanceSmart(
            leftScreen: leftScreen,
            rightCameraPose: perspectiveCameraData.rightEyeCameraPose,
            intrinsic: perspectiveCameraData.simpleIntrinsic,
            startLow: ScreenDistanceOptimizer.defaultScreenDistance,
            maxHigh: ScreenDistanceOptimizer.defaultScreenDistance * ScreenDistanceOptimizer.defaultHighMultiplier * 2
        ) {
            return result.minDistance
        }
        
        throw SearchNoResult()
    }
    
    struct SearchNoResult: LocalizedError {
        public var errorDescription: String? {
            "Optimization algorithm failed"
        }
    }
}
