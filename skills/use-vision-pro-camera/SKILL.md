---
name: use-vision-pro-camera
description: 构建 Vision Pro 应用。提供穿透相机捕获、双目投影、四边形裁切、立体材质渲染、手势追踪、像素反投影为世界射线（点击屏幕获取世界射线）、调试可视化等完整功能的代码模式。当用户要基于 VisionPro 主摄像头开发应用、添加相机功能、实现空间取景框、处理沉浸式空间生命周期、将像素坐标转换为3D射线、或者询问 VisionPro 相机 API 的使用方式时使用。
---

# 使用Apple Vision Pro的摄像头
## 背景和主流程
在Vision Pro上，AVCapture只能让你获取到自拍摄像头（虚拟自影像）。
苹果在2024年（visionOS 2.0）开放了Vision Pro的主摄像头访问，在2025年开放了对左右双摄像头的访问。
这不没有违背发布Apple Vision Pro时的隐私承诺，因为这些访问仅适用于不上架AppStore的App，仅适用于企业内部分发的应用，在受控的环境下使用。
摄像头访问的都起源于[CameraFrameProvider](https://developer.apple.com/documentation/arkit/cameraframeprovider)这个API。
由于我们的项目需要使用摄像头，因此你在编写有关该API的代码前需要仔细阅读CameraFrameProvider.md。
在获取到摄像头画面之后，通常还希望能进行和3D坐标的互操作性。比如将RealityKit 3D空间中的一个坐标，转为摄像头画面中的2D坐标，摄像头画面中的2D坐标转为RealityKit 3D空间中的一条射线。你阅读Projector.swift、IntrinsicsAndExtrinsics.swift、CameraToWorld.swift就可以理解怎么做到这些。
当你读完这三个文件，你会意识到内参和外参是关键，我们要如何获取到这个内参和外参呢？已知在同一个相机配置（CameraVideoFormat）中，内参外参是确定的。项目中的代码为了分明说明起见，分别 获取内参和外参 和 运行相机帧流 ，在实践中可以合在一起做。
Showcase.md描述了在几个典型场景下，我们是如何利用这个VisionProKit的。
你不需要帮用户设置好访问主摄像头所需要的entitlements、permissions，直接修改xcproject文件是很危险的，总是让用户自己根据[文档](https://developer.apple.com/documentation/visionos/accessing-the-main-camera)去操作。
这个VisionProKit包不需要你集成到项目里，你要用的时候，手工在项目里自己也重新写一遍即可。

## 主流程外的单项说明

### 88d7333b-4547-4c5d-b557-a549880536ac
CameraFrame.Sample是@unchecked Sendable, CustomStringConvertible, Equatable的，可以跨 actor 传递的，具体可见CameraFrameProvider.swift。
CameraFrame.Sample.pixelBuffer——这是以前的，返回一个CVPixelBuffer，已经被标注deprecated了
（详见ARKit.swift，该文件长```bash
wc ARKit.swift
4321   22187  169495 ARKit.swift
```，请搜索式浏览）
现在使用CameraFrame.Sample.buffer，返回一个CVReadOnlyPixelBuffer。你需要把它转为CGImage来进行后续处理，具体见CVPixelBufferToCGImage.swift。
CameraPosition枚举在CameraFrameProvider.CameraPosition，地面真相来自ARKit.swift。

### d8ccfc65-57ba-4ffa-b5eb-51325f34a037
相机外参的坐标系转换```swift
// OpenCV → RealityKit 坐标系
// 绕 X 轴旋转，翻转 Y 和 Z
let rot = rotationX(Double.pi)
let pose = (rot * viewMatrix).inverse
```是visionOS 26的CameraFrameProvider实现的feature，在visionOS 26内、WWDC 27之前，这是保证的，经过真机测试、经过真人测试。

### 8df99543-c000-4392-90dd-b148c838c532
如果我们需要对SwiftUI的状态属性变化来控制RealityKit，不需要使用难用的update闭包。我们的最佳实践是：
先在视图/模型里持有
let root = Entity()
然后在
RealityView { content in
	content.add(root) // content是.add，不是.addChild。可以参考RealityViewContent.swift。
}
接下来当你提供.onChange()视图修饰符获取到了Swift UI状态属性的变化，然后在root上添加实体。

### f2d24f71-3cb3-4fb5-ad12-7b51fcb5c8e1
如果我们希望在RealityKit.Entity上附加SwiftUI View，我们不需要使用Attachment。
visionOS 26已经给我们提供了更多的好东西。你不需要担心兼容性，我们的整个项目已经被设为visionOS 26。
我们可以直接
let window = Entity()
window.components.set(ViewAttachmentComponent(rootView: ErrorView(error: errorMessage)))
window.components.set(BillboardComponent())
root.addChild(window)
这里提到的ViewAttachmentComponent、BillboardComponent，你可以在RealityKit.swift（该文件长```bash
wc RealityKit.swift   
58803  355286 2693662 RealityKit.swift
```，请搜索式浏览）查看。

### 计算机视觉相关
在visionOS 26，我们已经有了新的Vision框架的API，比如我们要人脸检测，我们不使用VNDetectFaceRectanglesRequest，而是使用DetectFaceRectanglesRequest，后者使用Swift Concurrency、结构化错误、Swift 6 兼容。
详细看“Vision.swift”（该文件较长
```bash
wc Vision.swift
13045   79318  585866 Vision.swift
```
搜索后再查看相关内容）
Apple Vision Pro的性能足够（M系列芯片），你可以对图像进行下采样（比如从1080P采样到720P、540P），但不要降低到480P、360P、270P，因为CameraFrameProvider给你的是左右摄像头画面，这些是第一人称视角的超广角相机，视野范围比手机广，同样大的物体在视野里占的比例（相比手机的广角摄像头）更小，因此需要足够的分辨率来确保可识别。从较高的下采样起点开始，当用户和你抱怨性能问题了再下降。
当我们通过双目来获得同一个物体/人脸在左右眼各自的边界框，然后希望以此做一个双目深度估计的时候，我们直觉想到双目上的同一个点会各自在现实世界中converge，但别忘了这“同一个点”是通过检测出来的，可能有几像素的误差，因此我们要找的不是两条射线的交点，而是两条射线最近的哪个点。这个“最近”，可以从0.5米开始取，如果用户抱怨太宽松了，我们可以再收紧。
图像是否需要灰度化、用灰度提升效率？不需要，Vision框架为彩色优化，你得不到多少性能收益，并且Apple Vision Pro的性能足够（M系列芯片），即使用户抱怨性能问题你也应该先考虑降低分辨率和帧率，而不是灰度化。
检测失败后是否保留上一帧位置？可以保留约 1 秒，除非用户抱怨了这事。因为Vision Pro的主摄像头是第一人称的——没有防抖，用户头部转头、走路的时候，会有拖影——提供几百毫秒的防丢是很合理的。

### 语音识别相关
如果你的应用需要语音识别，你肯定绕不开录音——AVAudioEngine在visionOS上是fully support的，你可以在AVAudioEngine.swift（该文件长```bash
wc AVAudioEngine.swift
903    5259   41434 AVAudioEngine.swift
```，请搜索式浏览）确认。
默认使用Locale.current即可，不因为我们使用中文聊天而认为要硬编码中文。

### 510a1169-7592-4445-9ffc-767301ef1cf7
simd_double4x4 → simd_float4x4、simd_float4x4 → simd_double4x4的转换可以参考
```swift
extension simd_double4x4 {
    init(_ floatMatrix: simd_float4x4) {
        self.init(
            columns: (
                SIMD4<Double>(Double(floatMatrix.columns.0.x), Double(floatMatrix.columns.0.y), Double(floatMatrix.columns.0.z), Double(floatMatrix.columns.0.w)),
                SIMD4<Double>(Double(floatMatrix.columns.1.x), Double(floatMatrix.columns.1.y), Double(floatMatrix.columns.1.z), Double(floatMatrix.columns.1.w)),
                SIMD4<Double>(Double(floatMatrix.columns.2.x), Double(floatMatrix.columns.2.y), Double(floatMatrix.columns.2.z), Double(floatMatrix.columns.2.w)),
                SIMD4<Double>(Double(floatMatrix.columns.3.x), Double(floatMatrix.columns.3.y), Double(floatMatrix.columns.3.z), Double(floatMatrix.columns.3.w))
            )
        )
    }
}

func convertToFloat4x4(from doubleMatrix: double4x4) -> float4x4 {
        return float4x4(
            columns: (
                SIMD4<Float>(Float(doubleMatrix.columns.0.x), Float(doubleMatrix.columns.0.y), Float(doubleMatrix.columns.0.z), Float(doubleMatrix.columns.0.w)),
                SIMD4<Float>(Float(doubleMatrix.columns.1.x), Float(doubleMatrix.columns.1.y), Float(doubleMatrix.columns.1.z), Float(doubleMatrix.columns.1.w)),
                SIMD4<Float>(Float(doubleMatrix.columns.2.x), Float(doubleMatrix.columns.2.y), Float(doubleMatrix.columns.2.z), Float(doubleMatrix.columns.2.w)),
                SIMD4<Float>(Float(doubleMatrix.columns.3.x), Float(doubleMatrix.columns.3.y), Float(doubleMatrix.columns.3.z), Float(doubleMatrix.columns.3.w))
            )
        )
}
```的逐列转换——是唯一正确方式。（不信你可以去Vector.swift、simd.swift（该文件长```bash
wc simd.swift
2958   14065  106902 simd.swift
wc Vector.swift
19784  100484  702373 Vector.swift
```，请搜索式浏览）找，没有）

### 03bac585-dcd2-432c-b193-8c146ce70354
CIContext是`class CIContext : NSObject, @unchecked Sendable {}`的，详见CIContext.swift（该文件长```bash
wc CIContext.swift
625    4399   32552 CIContext.swift
```，请搜索式浏览）
CIContext不轻量，也没那么重，只要你不每帧allocate一个CIContext，你可以放心的在每个线程里各使用一个CIContext，不用想尽办法全局（跨线程）共享。