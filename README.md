# VisionProKit

面向 Apple Vision Pro 的空间相机与投影管线框架，提供双目相机采集、3D 几何投影、图像裁切、屏幕实体构建与沉浸式空间生命周期管理的完整能力。

## 平台要求

| 平台 | 最低版本 |
|------|----------|
| visionOS | 26 |
| macOS | 26 |
| iOS | 26 |

- Swift 工具链：6.2
- 依赖框架：ARKit · RealityKit · Spatial · SwiftUI · Combine · AVFoundation · CoreImage

---

## 功能特性

- **双目相机采集**：基于 ARKit `CameraFrameProvider`，"零延迟快门"策略 + 降噪处理
- **3D → 2D 投影**：针孔相机模型，世界坐标与像素坐标双向转换
- **屏幕计算**：按距离计算屏幕 pose 与物理尺寸，支持双目不相交距离优化
- **透视裁切**：CoreImage 四边形透视矫正，三种严格度模式
- **屏幕实体**：RealityKit 平面实体 + USDA ShaderGraph 立体材质（颜色准确）
- **生命周期管理**：可靠检测沉浸式空间关闭，确保 `onDisappear` 正确触发
- **权限管理**：统一请求手部追踪与相机访问权限
- **调试可视化**：点、射线、坐标轴的 3D 实时可视化

---

## 安装

通过 Swift Package Manager 添加依赖：

1. 在 Xcode 中选择 **File → Add Package Dependencies**
2. 输入本仓库地址
3. 选择目标平台版本（最低 26）
4. 点击 **Add Package**

---

## 快速开始

### 推荐调用顺序

```
权限请求 → 启动相机 → 获取内外参 → 构建透视数据 → 投影/屏幕计算 → 图像裁切 → 注册销毁检测
```

### 第一步：请求权限

```swift
// 在进入沉浸式空间前调用
// 注意：手部追踪权限只能在沉浸式空间内请求
try await requestHandAndCameraAuthorization()
```

### 第二步：启动相机

```swift
let camera = CameraWithHead()

// 启动 ARKit 会话与相机帧流
try await camera.runCameraFrameProvider()

// 拍照（返回左右目 CGImage + 头部 Transform）
let photo = try await camera.takePhoto()
// photo.left   — 左目 CGImage（已降噪）
// photo.right  — 右目 CGImage（已降噪）
// photo.head   — 头部姿态 Transform
```

### 第三步：获取内外参（一次性）

```swift
let intrinsicsAndExtrinsics = try await GetIntrinsicsAndExtrinsics()
    .getIntrinsicsAndExtrinsics()
```

### 第四步：3D → 2D 投影

```swift
let projector = ThreeDTo2DProjector(
    camera: .left,
    intrinsicsAndExtrinsics: intrinsicsAndExtrinsics
)

// 将 3D 取景框四角点投影为 2D 像素坐标
let corners2D = try projector.to2DCornersPoint(
    corners: viewfinderCorners3D,
    headTransform: photo.head
)

// 或直接计算屏幕姿态与尺寸
let screen = try projector.getScreenDirect(
    headTransform: photo.head,
    distance: 1.0
)
// screen.pose — 屏幕位姿 Transform
// screen.size — 屏幕物理尺寸 Size2D
```

### 第五步：图像裁切

```swift
let cropper = QuadrilateralCropper()

// 三种严格度：.loose / .normal / .strict
let croppedImage = try await cropper.cropInViewfinderPart(
    image: photo.left,
    twoDCorners: corners2D,
    strictness: .normal
)
```

### 第六步：注册沉浸式空间销毁检测

```swift
// 在 RealityView 启动时注册
let detector = ImmersiveSpaceDestoryDetector()
detector.listenWillClose(baseEntity: myBaseEntity)

// 在视图修饰器中使用（置于最外层）
RealityView { ... }
    .modifier(TriggerRealityViewDisappear())
    .onDisappear {
        // 资源释放
    }
```

---

## 模块结构

```
Sources/VisionProKit/
├── PassthroughCamera/     # 相机系统：双目帧采集、拍照、降噪
│   ├── CameraWithHead.swift
│   └── CVPixelBufferToCGImage.swift
├── Projection/            # 投影系统：内外参、坐标变换、屏幕计算
│   ├── Projector.swift
│   ├── WorldToCamera.swift
│   ├── CameraToWorld.swift
│   ├── ScreenCalculator.swift
│   ├── ScreenDistanceOptimizer.swift
│   ├── ScreenIntersectionChecker.swift
│   ├── FrustumModel.swift
│   ├── IntrinsicsAndExtrinsics.swift
│   ├── SharedDataStruct.swift
│   └── SharedExtension.swift
├── Crop/                  # 图像裁切系统：四边形透视裁切
│   ├── Cropper.swift
│   ├── QCDataStruct.swift
│   └── Debug.swift
├── Screen/                # 屏幕实体：RealityKit 平面实体构建
│   └── ScreenEntity.swift
├── Stereo/                # 立体视觉：ShaderGraph 双目材质
│   └── StereoMaterialModel.swift
├── Foundations/           # 基础设施：线性代数、头部/手部模型
│   ├── LinearAlgebra.swift
│   ├── HeadModel.swift
│   └── HandControlPointModel.swift
├── Lifecycle/             # 生命周期管理：沉浸式空间销毁检测
│   └── Lifecycle.swift
├── Permission/            # 权限管理：手部追踪 + 相机访问
│   └── PermissionRequest.swift
└── Debug/                 # 调试可视化：点/射线/坐标轴 3D 渲染
    └── DebugVisualize.swift
```

---

## 核心 API 参考

### 相机系统

| 类型 | 说明 |
|------|------|
| `CameraWithHead` | 主相机类，`@Observable` |
| `runCameraFrameProvider()` | 启动 ARKit 会话与帧流 |
| `takePhoto() → Photo` | 拍照，返回降噪后的左右目图像与头部姿态 |
| `Photo` | `left: CGImage, right: CGImage, head: Transform` |
| `LatestRawFrame` | 内部缓存帧，用于零延迟快门 |

### 投影系统

| 类型 | 说明 |
|------|------|
| `ThreeDTo2DProjector` | 3D 角点 → 2D 像素坐标 |
| `PerspectiveCameraData` | 单眼内参 + 左右眼相机姿态 + 分辨率 |
| `WorldToCamera` | 世界坐标 → 相机像素（含 Y 轴翻转） |
| `CameraToWorld` | 相机像素 → 世界射线（用于 hit-test） |
| `ScreenCalculator` | 按距离计算屏幕 pose 与 size |
| `ScreenDistanceOptimizer` | 二分搜索左右眼不相交最小距离 |

### 图像裁切

| 类型 | 说明 |
|------|------|
| `QuadrilateralCropper` | 四边形裁切入口 |
| `CropStrictness` | `.loose` / `.normal` / `.strict` |
| `QuadrilateralCropActor` | 后台透视变换 Actor |

### 生命周期 & 权限

| 类型 | 说明 |
|------|------|
| `requestHandAndCameraAuthorization()` | 统一权限请求 |
| `ImmersiveSpaceDestoryDetector` | 沉浸式空间销毁检测 |
| `onClosingImmersiveSpace` | Combine 关闭信号 |
| `TriggerRealityViewDisappear` | ViewModifier，确保 onDisappear 触发 |

---

## 关键数据结构

```swift
// 透视相机数据（投影所需的完整数据）
struct PerspectiveCameraData {
    var simpleIntrinsic: SingleEyeIntrinsic.SimpleCameraIntrinsic  // VFOV + 宽高比
    var leftEyeCameraPose: Transform
    var rightEyeCameraPose: Transform
    var resolution: Size2D
}

// 拍照结果
struct Photo {
    let left: CGImage    // 左目（已降噪）
    let right: CGImage   // 右目（已降噪）
    let head: Transform  // 头部姿态
}

// 屏幕位姿与尺寸
struct ScreenPoseAndSize {
    let pose: Transform
    let size: Size2D
}
```

---

## 故障排除

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 相机启动失败 | 相机权限未授予 | 调用 `requestHandAndCameraAuthorization()` |
| 帧未就绪（`frameNotReady`） | 帧流未稳定 | 等待相机流稳定后再调用 `takePhoto()` |
| 点在相机后方 | 3D 角点不在相机前方 | 确保世界坐标点的 z < 0（相机空间） |
| 外参非刚性变换 | 含缩放/剪切 | 检查 ARKit 外参来源与坐标系转换链路 |
| 裁切无交集错误 | 四边形超出图像 | 切换为 `.loose` 严格度或调整角点 |
| `onDisappear` 不触发 | RealityView 未从视图树移除 | 使用 `ImmersiveSpaceDestoryDetector` + `TriggerRealityViewDisappear` |
| 手部权限失败 | 在非沉浸式空间请求 | 确保在 ImmersiveSpace 内请求手部追踪权限 |
| 模拟器运行报错 | ARKit 仅真机可用 | 在 Vision Pro 真机上部署运行 |

---

## 性能建议

- **相机**：帧转换与降噪仅在拍照时执行，避免每帧处理
- **投影**：缓存 `PerspectiveCameraData`，避免重复构建；内外参一次性获取
- **裁切**：`QuadrilateralCropActor` 后台异步执行，避免主线程阻塞
- **纹理**：立体材质关闭压缩以保证颜色准确，注意大分辨率场景下的内存峰值
- **调试**：`DebugVisualizationModel` 仅在开发阶段启用

---

## License

本项目遵循所在仓库的许可协议。
