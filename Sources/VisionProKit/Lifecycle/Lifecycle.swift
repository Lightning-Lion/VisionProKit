import os
import Combine
import SwiftUI
import Spatial
import ARKit
import RealityKit

// MARK: - onClosingImmersiveSpace
/// 沉浸式空间关闭信号
@MainActor
public let onClosingImmersiveSpace = PassthroughSubject<Void, Never>()


// MARK: - ImmersiveSpaceDestoryDetector
/// 沉浸式空间销毁检测器
/// 侦测RealityView的销毁
/// 以发出清理操作
@MainActor
@Observable
public class ImmersiveSpaceDestoryDetector {
    private var eventSource: Cancellable? = nil
    private var count = 0
    private var triggered = false
    
    public init() {}
    
    // 实测
    // 1.于ManipulateComponent交互后
    // 2.因为PhotoView呈现照片的时候使用了RealityView
    // 会导致外界RealityView无法正常销毁（也就是ImmersiveSpace会被迫销毁，但其中的RealityView无法正常释放）
    // 通过测试，ImmersiveView销毁时候，会触发SceneEvents.AnchoredStateChanged，我们通过这一点来确认。
    public func listenWillClose(baseEntity: Entity) {
        Task { @MainActor in
            do {
                // 要等待baseEntity进入场景，才能设置订阅
                // 这个过程应该很快，用不了几秒，轮询一下好了
                let scene = try await getScene(baseEntity: baseEntity)
                let head = AnchorEntity(.head)
                baseEntity.addChild(head)
                // 设置订阅
                eventSource = scene.subscribe(to: SceneEvents.AnchoredStateChanged.self) { event in
                    self.onEvent(event: event, head: head)
                }
                os_log("已成功设置订阅")
            } catch {
                os_log("订阅失败")
                os_log("\(error.localizedDescription)")
            }
        }
    }
    
    // 要等待baseEntity进入场景，才能设置订阅
    // 因为传入的是Entity，而我们需要在Scene上才能.subscribe()。
    // 或者RealityViewContent也能.subscribe()，但RealityViewContent是inout的，不适合传来传去
    // 这个过程应该很快，用不了几秒，轮询一下好了
    private func getScene(baseEntity: Entity) async throws -> RealityKit.Scene {
        while true {
            if let scene = baseEntity.scene {
                // 得到目标了，返回
                return scene
            } else {
                // 等一帧再试试
                try await Task.sleep(for: .seconds(1.0 / 120))
            }
        }
    }
    
    private func onEvent(event: SceneEvents.AnchoredStateChanged, head: AnchorEntity) {
        // 头的跟踪丢失了，那就是ImmersiveSpace关闭了
        if event.anchor == head && event.isAnchored == false && head.isAnchored == false && head.isActive == false && head.isEnabledInHierarchy == false {
            // 只触发一次关闭
            if self.triggered == false {
                self.triggered = true
                os_log("ImmersiveSpace要销毁了")
                onClosingImmersiveSpace.send()
            }
        }
    }
}

// MARK: - TriggerRealityViewDisappear
/// 触发RealityView销毁修饰器
/// 注：此修饰器使用 AppModel 环境对象，项目需自行提供符合要求的 AppModel
/// 因为 AppModel 包含项目特定的沉浸式空间ID等信息，不适合放入通用包
/// 项目应自行实现类似逻辑，参考 EyeCover/EyePack/LifeCycle.swift 中的 TriggerRealityViewDisappear
///
/// ---
/// ## 背景
/// 在 ImmersiveSpace 中使用 RealityView 时，若直接关闭沉浸式空间，
/// RealityView 上绑定的 `onDisappear` 回调不会被正常触发。
/// 解决方案是监听 `onClosingImmersiveSpace` 信号，主动将 RealityView 从视图树中移除，
/// 从而让 `onDisappear` 得到正确调用。
///
/// ## 示例 1：不依赖 AppModel 的极简版本（推荐）
/// 适合不需要在 AppModel 中追踪沉浸式空间状态的场景。
/// ```swift
/// struct TriggerRealityViewDisappear: ViewModifier {
///     @State private var alive = true
///     func body(content: Content) -> some View {
///         VStack {
///             if alive {
///                 content
///             }
///         }
///         .onReceive(onClosingImmersiveSpace) { _ in
///             alive = false
///         }
///     }
/// }
/// ```
///
/// ## 示例 2：依赖 AppModel，同步沉浸式空间状态
/// 适合需要在 AppModel 中维护 `immersiveSpaceState` 的场景。
/// ```swift
/// struct TriggerRealityViewDisappear: ViewModifier {
///     @Environment(AppModel.self) private var appModel
///     @State private var alive = true
///     func body(content: Content) -> some View {
///         VStack {
///             if alive {
///                 content
///                     .onAppear {
///                         appModel.immersiveSpaceState = .open
///                     }
///                     .onDisappear {
///                         appModel.immersiveSpaceState = .closed
///                     }
///             }
///         }
///         .onReceive(onClosingImmersiveSpace) { _ in
///             alive = false
///         }
///     }
/// }
/// ```
///
/// ## 用法
/// 将此修饰器包裹在最外层的 `ViewModifier` 上，确保它能覆盖整个 RealityView 的生命周期：
/// ```swift
/// struct MyImmersiveSpaceModifier: ViewModifier {
///     func body(content: Content) -> some View {
///         content
///             .modifier(SomeInnerModifier())
///             // 包在最外层，保证 onDisappear 被正确触发
///             .modifier(TriggerRealityViewDisappear())
///     }
/// }
/// ```
///
/// ## 配合 ImmersiveSpaceDestoryDetector 使用
/// `TriggerRealityViewDisappear` 依赖 `onClosingImmersiveSpace` 信号，
/// 该信号由 `ImmersiveSpaceDestoryDetector.listenWillClose(baseEntity:)` 发出。
/// 需在 RealityView 启动时注册监听：
/// ```swift
/// @MainActor
/// @Observable
/// class MyModel {
///     private var deiniter = ImmersiveSpaceDestoryDetector()
///
///     func run(baseEntity: Entity) async {
///         // 注册 ImmersiveSpace 销毁事件，触发后会发出 onClosingImmersiveSpace 信号
///         deiniter.listenWillClose(baseEntity: baseEntity)
///     }
/// }
/// ```
