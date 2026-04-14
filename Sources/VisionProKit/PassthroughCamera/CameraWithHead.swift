import os
import SwiftUI
import ARKit
import RealityKit
import AVFoundation

// MARK: - CameraWithHead
/// 头部相机管理器
/// 捕获双目照片并附带头部姿态信息
/// 封装了ARKit的CameraFrameProvider，提供简洁的拍照接口
/// 出错时通过沉浸式空间内的弹窗显示错误信息
@MainActor
@Observable
public class CameraWithHead {
    public var task: Task<Void, Never>? = nil
    public var error: Error? = nil
    private var arkitSession: ARKitSession? = nil
    private let worldTracking: WorldTrackingProvider = WorldTrackingProvider()
    private var cameraFrameProvider: CameraFrameProvider? = nil
    // 因为我们没法在调用takePhoto()去CameraFrameProvider获取.currentFrame（它的设计不提供这个属性），我们只能持续存储每一帧，然后在takePhoto()的时候拿最后一帧，这刚好也实现了零延迟快门（甚至还有略微提前）
    private var latest: LatestRawFrame? = nil
    private let context = CIContext(options: nil)
    
    public init() {}
    
    public func runCameraFrameProvider() async throws {
        let arkitSession = ARKitSession()
        let authorizationStatus = await arkitSession.requestAuthorization(for: [.cameraAccess])
        
        guard authorizationStatus[.cameraAccess] == .allowed else {
            throw RunCameraFrameProviderError()
        }
        
        let cameraFrameProvider = CameraFrameProvider()
        try await arkitSession.run([worldTracking, cameraFrameProvider])
        self.arkitSession = arkitSession
        self.cameraFrameProvider = cameraFrameProvider
        
        task = Task { @MainActor in
            do {
                try await observeCameraFrameUpdates(cameraFrameProvider: cameraFrameProvider)
                os_log("ImmersiveSpace关闭了")
            } catch {
                self.error = error
                os_log("相机流出错：\(error.localizedDescription)")
            }
        }
    }
    
    /// 拍照，返回左右目图像与头部姿态
    /// 设计为返回确切的错误，而不是一个nil了事
    /// 在这个时候才进行图片的处理，而不是每帧处理图片，降低发热
    public func takePhoto() async throws -> Photo {
        guard let latest else {
            throw TakePhotoError.frameNotReady
        }
        do {
            let leftRaw = try await latest.left.buffer.toCGImage(context: context)
            let rightRaw = try await latest.right.buffer.toCGImage(context: context)
            // 进行降噪
            let left = try leftRaw.denoised()
            let right = try rightRaw.denoised()
            return Photo(left: left, right: right, head: latest.head)
        } catch {
            os_log("\(error.localizedDescription)")
            throw TakePhotoError.conversationError
        }
    }
    
    private func observeCameraFrameUpdates(cameraFrameProvider: CameraFrameProvider) async throws {
        let desiredFormat = Self.getCameraVideoFormat()

        guard let desiredFormat,
              let cameraFrameUpdates: CameraFrameProvider.CameraFrameUpdates = cameraFrameProvider.cameraFrameUpdates(for: desiredFormat) else {
            throw ObserveCameraFrameUpdates()
        }
        
        // 遍历流
        // 阻塞不要紧
        for await cameraFrame in cameraFrameUpdates {
            guard !Task.isCancelled else {
                os_log("CameraFrameUpdates被取消了，可能是ImmersiveSpace已被关闭，我被通知释放")
                break
            }
            guard worldTracking.state == .running else {
                logWithInterval("因为世界跟踪不可用，暂不更新相机帧", tag: "d3de0c9e163840eaae60")
                continue
            }
            guard cameraFrameProvider.state == .running else {
                logWithInterval("因为CameraFrameProvider不可用，暂不更新相机帧", tag: "f84609f3-b984-4a96-bc89-c145cf8f2f70")
                continue
            }
            guard let leftSample = cameraFrame.sample(for: .left), let rightSample = cameraFrame.sample(for: .right) else {
                throw ObserveCameraFrameUpdates()
            }
            guard let head = getHead() else {
                logWithInterval("因为头部姿态不可用，暂不更新相机帧", tag: "7bb2ba40-f433-4474-acfa-74a3ef7bfc49")
                continue
            }
            latest = LatestRawFrame(left: leftSample, right: rightSample, head: head)
        }
        os_log("ImmersiveSpace关闭了")
    }
    
    private func getHead() -> Transform? {
        guard let anchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else {
            return nil
        }
        return Transform(matrix: anchor.originFromAnchorTransform)
    }
    
    // MARK: - LatestRawFrame
    /// 最新原始帧数据
    public struct LatestRawFrame {
        public var left: CameraFrame.Sample
        public var right: CameraFrame.Sample
        public var head: Transform
    }
    
    // MARK: - Photo
    /// 照片数据结构
    public struct Photo {
        public var left: CGImage
        public var right: CGImage
        public var head: Transform
        public init(left: CGImage, right: CGImage, head: Transform) {
            self.left = left
            self.right = right
            self.head = head
        }
    }
    
    public struct RunCameraFrameProviderError: LocalizedError {
        public var errorDescription: String? {
            "authorizationStatus[.cameraAccess] != .allowed"
        }
    }
    
    public struct ObserveCameraFrameUpdates: LocalizedError {
        public var errorDescription: String? {
            "cameraFrameProvider.cameraFrameUpdates() return nil"
        }
    }
    
    public enum TakePhotoError: LocalizedError {
        case frameNotReady
        case conversationError
        public var errorDescription: String? {
            switch self {
            case .frameNotReady:
                "还没有可用的帧"
            case .conversationError:
                "格式转换错误"
            }
        }
    }
    
    static
    internal func getCameraVideoFormat() ->  CameraVideoFormat? {
        let cameraPositions: [CameraFrameProvider.CameraPosition] = [.left, .right]
        let formats = CameraVideoFormat
            .supportedVideoFormats(for: .main, cameraPositions: cameraPositions)
            .filter({ $0.cameraRectification == .mono })
        
        let desiredFormat = formats.max { $0.frameSize.totalPixel < $1.frameSize.totalPixel }
        return desiredFormat
    }
}

// MARK: - CGImage降噪扩展
extension CGImage {
    public func denoised(noiseLevel: Float = 0.02, sharpness: Float = 0.4) throws -> CGImage {
        let ciImage = CIImage(cgImage: self)
        
        let filter = CIFilter.noiseReduction()
        filter.inputImage = ciImage
        filter.noiseLevel = noiseLevel
        filter.sharpness = sharpness
        
        guard let outputImage = filter.outputImage,
              let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
            throw DenoiseError.ciImageToCGImageFailed
        }
        
        return cgImage
    }
    
    public enum DenoiseError: LocalizedError {
        case ciImageToCGImageFailed
        public var errorDescription: String? {
            switch self {
            case .ciImageToCGImageFailed:
                "CIImage转换到CGImage失败"
            }
        }
    }
}

// MARK: 计算最高像素数扩展
extension CGSize {
    public var totalPixel: CGFloat {
        width * height
    }
}
