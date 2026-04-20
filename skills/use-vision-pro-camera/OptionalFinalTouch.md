# 后处理

> 这份文档里提供的是可选的增强，在已经实现了程序初版功能的基础上，再增加这些细节，可以让它在接下来的调试和开发过程中更加易用。

为权限控制流程提供明确的UI提示，包括获取权限失败、权限被拒绝，使用import Combine和PassthroughSubject<Error, Never>()来从任意位置向SwiftUI发送错误，SwiftUI侧可以拿到错误然后展示给用户。

对于上面已经有UI侧展示的错误，仍然需要使用
import os
os_log("<YOUR_MESSAGE>")
来发送日志到控制台，因为控制台可以跳转到日志发出的位置，有“Jump to source”按钮。这也提醒你不要二次封装日志方法，因为这会带上错误的行数跳转信息给控制台。把UI侧展示的错误也发到log，并且方便开发者批量复制日志，也方便你稍后提供终端看日志（如有需要）


为每帧/每秒触发的事件，提供合理的抽样日志，使用Logger来发出日志。
import os
nonisolated
private let logger = Logger(subsystem: "<YOUR_SUBSYSTEM>", category: "debug")
为每个模块使用不同的subsystem，这样开发者可以在终端里筛选某个subsystem的日志。