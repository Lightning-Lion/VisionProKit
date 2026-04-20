## Pattern A：全视野穿透替换

> 用途：将穿透相机画面实时替换为经过处理的图像。适用于实时视觉滤镜、AI/CV 算法可视化、风格迁移、端到端延迟测试等。

### 核心流程

```
获取内外参 → 启动相机流 → 触发刷新 → 拍照
         → 计算左眼屏幕 Pose/Size（固定 30m）
         → 二分搜索右眼最小不重叠距离
         → buildScreenEntity × 2 → 添加到场景
```

### 完整 Model 代码

```swift
import VisionProKit

@MainActor @Observable
class YourCameraModel {
    private var cameraModel = CameraWithHead()
    private var projectorLeft: ThreeDTo2DProjector? = nil
    private var projectorRight: ThreeDTo2DProjector? = nil
    private var deiniter = ImmersiveSpaceDestoryDetector()
    private var currentLeftScreen: Entity? = nil
    private var currentRightScreen: Entity? = nil

    func run(baseEntity: Entity, dismissImmersiveSpace: DismissImmersiveSpaceAction) async {
        deiniter.listenWillClose(baseEntity: baseEntity)
        do {
            let ie = try await GetIntrinsicsAndExtrinsics().getIntrinsicsAndExtrinsics()
            projectorLeft  = ThreeDTo2DProjector(camera: .left,  intrinsicsAndExtrinsics: ie)
            projectorRight = ThreeDTo2DProjector(camera: .right, intrinsicsAndExtrinsics: ie)
            try await cameraModel.runCameraFrameProvider()
        } catch {
            await dismissImmersiveSpace()
        }
    }

    func refreshScreen(baseEntity: Entity) async {
        guard let projectorLeft, let projectorRight else { return }
        do {
            currentLeftScreen?.removeFromParent()
            currentRightScreen?.removeFromParent()

            let photo = try await cameraModel.takePhoto()

            // 左眼：固定距离 30m
            let (leftPose, leftSize) = try await projectorLeft.getScreenDirect(
                head: photo.head, distance: ScreenDistanceOptimizer.defaultScreenDistance)

            // 右眼：二分搜索最小不重叠距离（IPD 导致右眼需略远）
            let rightDistance = try await projectorRight.getOptimizedRightScreenDistance(
                head: photo.head, leftScreenPose: leftPose, leftScreenSize: leftSize)
            let (rightPose, rightSize) = try await projectorRight.getScreenDirect(
                head: photo.head, distance: rightDistance)

            currentLeftScreen  = try await buildScreenEntity(
                image: photo.left,  screenPose: leftPose,  screenPhysicalSize: leftSize,  visibleEye: .left)
            currentRightScreen = try await buildScreenEntity(
                image: photo.right, screenPose: rightPose, screenPhysicalSize: rightSize, visibleEye: .right)

            baseEntity.addChild(currentLeftScreen!)
            baseEntity.addChild(currentRightScreen!)
        } catch { /* 处理错误 */ }
    }
}
```

### buildScreenEntity 本地封装

VisionProKit 库的 `buildScreenEntity` 需要传入闭包，建议在 App 层封装简化版：

```swift
func buildScreenEntity(image: CGImage, screenPose: Transform,
                       screenPhysicalSize: Size2D, visibleEye: Device.Camera) async throws -> Entity {
    let entity = Entity()
    entity.setTransformMatrix(screenPose.matrix, relativeTo: nil)
    let clearMaterial = try await StereoMaterialModelActor().create1x1TransparentCGImage()
    let stereoMaterial: ShaderGraphMaterial = try await {
        switch visibleEye {
        case .left:  return try await StereoMaterialModel().createMaterial(leftEye: image, rightEye: clearMaterial)
        case .right: return try await StereoMaterialModel().createMaterial(leftEye: clearMaterial, rightEye: image)
        }
    }()
    entity.components.set(ViewAttachmentComponent(
        rootView: ScreenEntityInner(image: stereoMaterial, imagePhysicalSize: screenPhysicalSize)))
    return entity
}
```

`ScreenEntityInner` 必须用 RealityKit `ModelEntity` 渲染（30m 处物理尺寸极大，SwiftUI `Image` 会被裁切或变透明）：

```swift
struct ScreenEntityInner: View {
    var image: ShaderGraphMaterial
    var imagePhysicalSize: Size2D
    @PhysicalMetric(from: .meters) private var pointsPerMeter: CGFloat = 1
    var body: some View {
        RealityView { content in
            let plane = ModelEntity(
                mesh: .generatePlane(width: Float(imagePhysicalSize.width),
                                     height: Float(imagePhysicalSize.height)),
                materials: [image])
            content.add(plane)
        }
        .frame(width: pointsPerMeter * CGFloat(imagePhysicalSize.width),
               height: pointsPerMeter * CGFloat(imagePhysicalSize.height))
    }
}
```

---

## Pattern B：手势框选区域拍照裁切

> 用途：双手在空间中比出矩形区域，捏合手势触发拍照并精确裁切该区域。适用于空间截图、AR 标注、定向图像采集等。

### 核心流程

```
申请权限 → HeadAxisModel + HandControlPointModel
         → 120FPS 用双手控制点计算取景框 Pose/Size
         → 捏合手势 → CameraWithHead.takePhoto()
         → ThreeDTo2DProjector.to2DCornersPoint()（3D角点 → 2D像素角点）
         → QuadrilateralCropper.cropInViewfinderPart()（透视裁切）
```

### 权限申请（必须在 ImmersiveSpace 内）

```swift
try await requestHandAndCameraAuthorization()
```

### 头部和手部追踪

```swift
let headModel = HeadAxisModel()
let handModel = HandControlPointModel()

try await headModel.run()
await handModel.run(baseEntity: baseEntity)

// 每帧查询（120FPS loop）
guard let head = headModel.getHeadTransform() else { return }
guard let (leftPoint, rightPoint) = handModel.getControlPoint(baseEntity: baseEntity) else { return }
// leftPoint/rightPoint：左右手拇指+食指中点，Point3D 世界坐标
```

### 3D → 2D 投影并裁切

```swift
let projectorLeft  = ThreeDTo2DProjector(camera: .left,  intrinsicsAndExtrinsics: ie)
let projectorRight = ThreeDTo2DProjector(camera: .right, intrinsicsAndExtrinsics: ie)

// cornersPose：取景框四个 3D 角点（ThreeDTo2DProjector.ViewfinderOrnamentCornersPose）
let corners2DLeft  = try await projectorLeft.to2DCornersPoint(cornersPose: cornersPose, head: photo.head)
let corners2DRight = try await projectorRight.to2DCornersPoint(cornersPose: cornersPose, head: photo.head)

let croppedLeft  = try await QuadrilateralCropper().cropInViewfinderPart(
    image: photo.left,  twoDCorners: corners2DLeft,  strictness: .loose)
let croppedRight = try await QuadrilateralCropper().cropInViewfinderPart(
    image: photo.right, twoDCorners: corners2DRight, strictness: .loose)
```

`CropStrictness` 说明：
- `.loose` 超出边界显示透明（推荐，永不 throw）
- `.normal` 要求四边形与图像有交集
- `.strict` 四边形必须完全在图像内，否则 throw

---

## Pattern C：点击像素反投影为世界射线

> 用途：点击屏幕上任意像素，获得从该像素出发的世界坐标射线。适用于物体定位、空间 hitTest、AR 标注、场景理解等。

### 核心原理（四步流程）

```
① Y 轴翻转（图像 +Y向下 → 3D +Y向上）
   pixel_y = resolution.height - tapPoint.y

② 反透视投影到归一化平面（z = -1）
   dir = ((px - cx)/fx,  (py - cy)/fy,  -1.0)  ← 相机空间方向

③ 相机空间 → 世界空间（cameraPose × [dir | w=0]）
   w=0：只应用旋转，不受平移影响

④ 射线原点 = cameraPose.col3（相机在世界的真实位置）
```

### 构建 CameraToWorld

在 `refreshScreen` 拿到 `photo` 后，紧接着构建：

```swift
let perspectiveCameraData = try await projectorLeft.buildupPerspectiveData(
    head: photo.head,
    intrinsicsAndExtrinsics: projectorLeft.intrinsicsAndExtrinsics
)
let cameraToWorld = CameraToWorld(perspectiveCameraData: perspectiveCameraData)
```

将 `cameraToWorld` 传入 `buildScreenEntity`，使屏幕实体内部可以在点击时调用反投影：

```swift
let screen = try await buildScreenEntity(
    image: photo.left,
    screenPose: leftPose,
    screenPhysicalSize: leftSize,
    visibleEye: .left,
    cameraToWorld: cameraToWorld
)
```

### ScreenEntityInner 点击事件

```swift
struct ScreenEntityInner: View {
    var image: CGImage
    var imagePhysicalSize: Size2D
    var eye: Device.Camera
    var cameraToWorld: CameraToWorld
    @PhysicalMetric(from: .meters) private var pointsPerMeter: CGFloat = 1
    private var width:  CGFloat { pointsPerMeter * CGFloat(imagePhysicalSize.width) }
    private var height: CGFloat { pointsPerMeter * CGFloat(imagePhysicalSize.height) }

    var body: some View {
        Image(image, scale: 1.0, label: Text("")).resizable()
            .onTapGesture(count: 1, coordinateSpace: .local) { tapPoint in
                // SwiftUI .local 坐标 → 1920×1080 像素空间
                let pixelPoint = Point2D(
                    x: tapPoint.x * 1920.0 / width,
                    y: tapPoint.y * 1080.0 / height
                )
                Task {
                    let ray = await cameraToWorld.cameraPointToWorldRay(
                        cameraPoint: pixelPoint, eye: eye)
                    await MainActor.run {
                        cameraRay.send((pixel: pixelPoint, ray: ray))
                    }
                }
            }
            .frame(width: width, height: height)
    }
}

// App 层定义的两个信号
@MainActor let cameraTapped = PassthroughSubject<Point2D, Never>()
@MainActor let cameraRay    = PassthroughSubject<(pixel: Point2D, ray: Ray3D), Never>()
```

### 接收射线并可视化

```swift
// 在 ViewModifier 的 body 中
.onReceive(cameraRay) { (pixel, ray) in
    let label = "px(\(Int(pixel.x)),\(Int(pixel.y)))"
    // 相同 tag → 复用同一实体（原地更新），不会堆积多条射线
    debugRayVisualization.send((label, (ray.origin, ray.direction), "tapRay"))
}
.modifier(EnableDebugVis(baseEntity: baseEntity))
```