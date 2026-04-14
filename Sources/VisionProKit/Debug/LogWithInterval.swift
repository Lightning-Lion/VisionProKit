import os
import SwiftUI

// MARK: - LogWithInterval
/// 间隔日志记录器
/// 用于控制日志输出频率，避免每帧输出导致的控制台刷屏
/// 通过tag区分不同的日志源，相同tag的日志在指定间隔内只输出一次
/// 注意：使用此方式会丢失jump to source功能，但可以通过tag搜索定位源代码
@MainActor
@Observable
public class LogWithInterval {
    public static let shared = LogWithInterval()
    private init() {}
    
    private var lastLogTime: [String: Date] = [:]
    
    public func logWithInterval(message: String, tag: String) {
        let current = Date.now
        if let lastTime = lastLogTime[tag] {
            let duration: TimeInterval = current.timeIntervalSince(lastTime)
            if duration < 2 {
                // 忽略
            } else {
                lastLogTime[tag] = Date.now
                os_log("[\(tag)]\(message)")
            }
        } else {
            lastLogTime[tag] = Date.now
            os_log("[\(tag)]\(message)")
        }
    }
}

// MARK: - logWithInterval
/// 全局间隔日志函数
/// - Parameters:
///   - message: 日志消息内容
///   - tag: 用于区分不同日志源的标识符
@MainActor
public func logWithInterval(_ message: String, tag: String) {
    LogWithInterval.shared.logWithInterval(message: message, tag: tag)
}
