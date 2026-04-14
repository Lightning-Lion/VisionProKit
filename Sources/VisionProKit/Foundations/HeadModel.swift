import os
import SwiftUI
import ARKit
import RealityKit

// MARK: - HeadAxisModel
/// 头部姿态模型
/// 基于ARKit世界跟踪提供设备姿态
@MainActor
@Observable
public class HeadAxisModel {
    private let arSession = ARKitSession()
    private let worldTracking = WorldTrackingProvider()
    
    public init() {}
    
    public func run() async throws {
        do {
            try await arSession.run([worldTracking])
        } catch {
            throw WorldTrackingLostError()
        }
    }
    
    public func getHeadTransform() -> Transform? {
        return getDeviceTransform(worldTracking: worldTracking)
    }
    
    private func getDeviceTransform(worldTracking: WorldTrackingProvider) -> Transform? {
        guard worldTracking.state == .running else {
            return nil
        }
        guard let anchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else {
            return nil
        }
        return Transform(matrix: anchor.originFromAnchorTransform)
    }
    
    public struct WorldTrackingLostError: LocalizedError {
        public var errorDescription: String? {
            "世界跟踪丢失"
        }
    }
}
