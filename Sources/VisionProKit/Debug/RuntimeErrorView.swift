import os
import SwiftUI
import RealityKit

// MARK: - RuntimeError
/// 运行时错误弹窗修饰器
/// 在沉浸式空间中显示错误弹窗，支持延迟显示和即时关闭
/// 适用于手势跟踪等可能快速恢复的场景，避免短暂错误频繁弹窗
/// 错误解除时弹窗会立即消失，发生错误时则按设定的延迟时间后显示
public struct RuntimeError: ViewModifier {
    public var errorMessage: String?
    // 发生错误延迟出现，错误解除立刻销毁
    // 适用于手势跟踪，短暂的丢失是正常的，如果一会儿就恢复了那就不需要弹出错误弹窗
    public var delay: TimeInterval
    public let baseEntity: Entity
    @State
    private var container: Entity? = nil
    @State
    private var showErrorDelay: Task<Void, Never>? = nil
    // 可变的错误消息，要更新错误，直接更改我即可
    // 不应该显示默认值。如果显示这句话，肯定是我们的逻辑写错了。
    @State
    private var changeableErrorMessage: String = "逻辑错误"
    @State
    private var userAllowToShowNewError = true
    
    public init(errorMessage: String?, delay: TimeInterval = 0, baseEntity: Entity) {
        self.errorMessage = errorMessage
        self.delay = delay
        self.baseEntity = baseEntity
    }
    
    public func body(content: Content) -> some View {
        content
            .onChange(of: errorMessage, initial: true) { oldValue, newValue in
                guard userAllowToShowNewError else {
                    // 不要再显示新的错误弹窗，现有的错误弹窗会由
                    // .onChange(of: showError, initial: true) { oldValue, newValue in
                    // 关闭的
                    return
                }
                if let newValue {
                    if oldValue == nil {
                        os_log("触发错误弹窗（等待延迟）")
                        showErrorDelay = Task { @MainActor in
                            do {
                                // 在延迟中错误解除了，就会直接throw
                                try await Task.sleep(for: .seconds(delay))
                                os_log("触发错误弹窗")
                                showPopup(errorMessage: newValue)
                            } catch {
                                // 错误解除了，或者
                                // 整个ViewModifier被销毁了，正常现象
                            }
                        }
                    } else {
                        os_log("更新错误弹窗")
                        // 直接跟新消息即可
                        self.changeableErrorMessage = newValue
                    }
                } else {
                    // 先前有错误弹窗，则关闭
                    if oldValue != nil {
                        dismissCurrentPopup()
                    }
                }
            }
            .onChange(of: userAllowToShowNewError, initial: true) { oldValue, newValue in
                if newValue == false {
                    dismissCurrentPopup()
                    // 新的错误弹窗会由
                    // guard showError else {
                    // 拦截的
                }
            }
    }
    
    private func showPopup(errorMessage: String) {
        let window = Entity()
        self.changeableErrorMessage = errorMessage
        window.components.set(ViewAttachmentComponent(rootView: RuntimeErrorView(error: $changeableErrorMessage, showError: $userAllowToShowNewError)))
        window.components.set(BillboardComponent())
        let head = AnchorEntity(.head)
        head.addChild(window)
        // 面前偏下，舒适的阅读位置，伸伸手也能触摸到
        window.position = [0, -0.1, -0.55]
        let container = Entity()
        self.container = container
        container.addChild(head)
        baseEntity.addChild(container)
    }
    
    // 强调current是因为会对当前弹窗做动画消失，在动画期间可以有新的弹窗出现
    private func dismissCurrentPopup() {
        os_log("关闭错误弹窗")
        showErrorDelay?.cancel()
        if let container {
            let containerCopy = container
            self.container = nil
            let opacityMod = OpacityComponent(opacity: 1)
            containerCopy.components.set(opacityMod)
            Entity.animate(.smooth) {
                containerCopy.components[OpacityComponent.self]?.opacity = 0
            } completion: {
                containerCopy.removeFromParent()
            }
        } else {
            os_log("找不到错误弹窗")
        }
    }
}

// MARK: - RuntimeErrorView
/// 运行时错误视图
/// 显示错误消息并提供关闭按钮
public struct RuntimeErrorView: View {
    @Binding
    public var error: String
    @Binding
    public var showError: Bool
    // 我来实现入场动画
    @State
    private var show = false
    // 出场动画通过OpacityComponent实现
    
    public init(error: Binding<String>, showError: Binding<Bool>) {
        self._error = error
        self._showError = showError
    }
    
    public var body: some View {
        if show {
            HStack {
                Text(error)
                Button {
                    showError = false
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonBorderShape(.circle)
            }
            .padding()
            .glassBackgroundEffect(in: .capsule)
            .transition(.opacity.animation(.smooth))
        } else {
            Color.clear
                .onAppear {
                    show = true
                }
        }
    }
}
