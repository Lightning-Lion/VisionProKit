import ARKit

// MARK: - requestAuthorization
/// 权限请求
/// .handTracking只能在ImmersiveSpace里调用，.cameraAccess在共享空间也能调用
@MainActor
public func requestHandAndCameraAuthorization() async throws {
    let result = await ARKitSession().requestAuthorization(for: [.handTracking, .cameraAccess])
    guard result.allSatisfy({ item in
        let status: ARKitSession.AuthorizationStatus = item.value
        switch status {
        case .notDetermined: return false
        case .allowed: return true
        case .denied: return false
        @unknown default: fatalError("未适配新系统")
        }
    }) else {
        throw RequestAuthorizationError()
    }
}

public struct RequestAuthorizationError: LocalizedError {
    public var errorDescription: String? {
        "未满足需要的权限：手部结构与动作、主相机"
    }
}
