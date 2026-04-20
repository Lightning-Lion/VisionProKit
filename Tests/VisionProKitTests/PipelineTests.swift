import Testing
import simd
import RealityKit
import Spatial
@testable import VisionProKit

// MARK: - 共享测试夹具（全部来自 log6.log / log9.log 实测数据）

/// Apple 转置约定 K 矩阵（log6: fx=fy=736.6339, cx=960, cy=540, 1920×1080）
/// Apple:  col0=(fx,0,cx)  col1=(0,fy,cy)  col2=(0,0,1)
/// OpenCV: col0=(fx,0,0)   col1=(0,fy,0)   col2=(cx,cy,1)
private let kMatrix_log6 = simd_double3x3(columns: (
    SIMD3<Double>(736.6339111328125, 0,               960.0),
    SIMD3<Double>(0,               736.6339111328125, 540.0),
    SIMD3<Double>(0,               0,                 1.0  )
))

/// log6 内参压缩结果
private let simpleIntrinsic_log6 = SingleEyeIntrinsic.SimpleCameraIntrinsic(
    yfov_radians: 1.2651476866718445,  // 72.4876°
    aspectRatio:  16.0 / 9.0
)

private let resolution_log6 = Size2D(width: 1920, height: 1080)

/// 左眼 ARKit 原始 E 矩阵（log6，列主序）
/// col3 = −Rᵀ·t = (0.02437, −0.02011, −0.05793)，不是相机位置
private let leftEyeE_log6 = simd_double4x4(columns: (
    SIMD4<Double>( 0.99162,  0.00114, -0.12920, 0),
    SIMD4<Double>(-0.01103, -0.99556, -0.09349, 0),
    SIMD4<Double>(-0.12873,  0.09413, -0.98720, 0),
    SIMD4<Double>( 0.024371616542339325, -0.02010880410671234, -0.057926394045352936, 1)
))

/// 右眼 ARKit 原始 E 矩阵（log6，列主序）
private let rightEyeE_log6 = simd_double4x4(columns: (
    SIMD4<Double>( 0.99027, -0.01281,  0.13856, 0),
    SIMD4<Double>(-0.00026, -0.99592, -0.09019, 0),
    SIMD4<Double>( 0.13915,  0.08928, -0.98624, 0),
    SIMD4<Double>(-0.024522092193365097, -0.020325442776083946, -0.05773836746811867, 1)
))

/// 合成测试相机：identity pose，fy=100，640×480（数值可精确验算）
private func syntheticData(fy: Double = 100, W: Double = 640, H: Double = 480) -> PerspectiveCameraData {
    PerspectiveCameraData(
        simpleIntrinsic: SingleEyeIntrinsic.SimpleCameraIntrinsic(
            yfov_radians: 2.0 * atan(H / 2.0 / fy),
            aspectRatio: W / H
        ),
        leftEyeCameraPose:  .identity,
        rightEyeCameraPose: .identity,
        resolutionV1: Size2D(width: W, height: H)
    )
}

// MARK: - Suite 1：内参压缩与重建

@Suite("内参 Intrinsics")
struct IntrinsicsTests {

    /// K → SimpleCameraIntrinsic 压缩无损（log6）
    /// 两个前提保证无损：① fx==fy（像素正方形）② cx==W/2, cy==H/2（主点在中心）
    @Test("K 压缩 → VFOV=1.26514768 rad, aspectRatio=16/9  ·  log6")
    func compressionLossless() throws {
        let i = try SingleEyeIntrinsic.leftEyeSimpleIntrinsic(
            leftEyeIntrinsics: kMatrix_log6,
            cameraImageSize: resolution_log6
        )
        // log6 实测: VFOV = 1.2651476866718445 rad = 72.4876°
        #expect(abs(i.yfov_radians - 1.2651476866718445) < 1e-10)
        #expect(abs(i.aspectRatio  - (16.0 / 9.0))       < 1e-10)
    }

    /// restoreIntrinsics 重建误差为零（log6）
    /// fy = (1080/2) / tan(72.4876°/2) = 540 / tan(36.2438°) = 736.6339px
    @Test("重建 fx/fy=736.6339, cx=960, cy=540（误差=0.000000px）  ·  log6")
    func restoreLossless() {
        let (fx, fy, cx, cy) = WorldToCamera.GetIntrinsics().restoreIntrinsics(
            simpleIntrinsic: simpleIntrinsic_log6,
            resolution: resolution_log6
        )
        #expect(abs(fx - 736.6339111328125) < 1e-6)
        #expect(abs(fy - 736.6339111328125) < 1e-6)
        #expect(abs(cx - 960.0)             < 1e-10)
        #expect(abs(cy - 540.0)             < 1e-10)
    }

    @Test("fx≠fy → fxNotEqualfy 错误")
    func errorFxNotEqualFy() {
        let K = simd_double3x3(columns: (
            SIMD3<Double>(700.0, 0, 960),  // fx=700 ≠ fy=736（像素非正方形）
            SIMD3<Double>(0, 736.0, 540),
            SIMD3<Double>(0, 0, 1)
        ))
        #expect(throws: SingleEyeIntrinsic.SimpleIntrinsicError.self) {
            try SingleEyeIntrinsic.leftEyeSimpleIntrinsic(
                leftEyeIntrinsics: K, cameraImageSize: resolution_log6)
        }
    }

    @Test("cx≠W/2 → widthOrHeightNotMatch 错误")
    func errorPrincipalPointOffCenter() {
        let K = simd_double3x3(columns: (
            SIMD3<Double>(736.0, 0, 900),  // cx=900 ≠ 1920/2=960（主点不在中心）
            SIMD3<Double>(0, 736.0, 540),
            SIMD3<Double>(0, 0, 1)
        ))
        #expect(throws: SingleEyeIntrinsic.SimpleIntrinsicError.self) {
            try SingleEyeIntrinsic.leftEyeSimpleIntrinsic(
                leftEyeIntrinsics: K, cameraImageSize: resolution_log6)
        }
    }
}

// MARK: - Suite 2：外参变换链

@Suite("外参变换链 getViewTransform")
struct ExtrinsicsTests {

    // 格式化辅助：保留 8 位小数，固定宽度对齐
    @MainActor private static let f8: (Double) -> String = { String(format: "% .8f", $0) }
    // 格式化辅助：保留 5 位小数
    @MainActor private static let f5: (Double) -> String = { String(format: "% .5f", $0) }

    /// col3 三阶段数值变化（log6 左眼）
    /// 阶段1: E.col3 = −Rᵀ·t（非位置）
    /// 阶段2: R_x(π)·E.col3（Y/Z 取反，仍是 View 的 col3）
    /// 阶段3: Pose.col3（求逆后，才是相机真实位置）
    @MainActor @Test("col3 三阶段: −Rᵀ·t → Y/Z取反 → 相机真实位置  ·  log6")
    func col3ThreeStages() throws {
        let E  = leftEyeE_log6
        let Rx = Transform(rotationDouble: simd_quatd(angle: .pi, axis: [1, 0, 0])).matrixDouble
        let f  = Self.f8

        // ── 阶段1: E.col3 ──────────────────────────────────────────────
        let c1 = E.columns.3
        print("""

╔═ [col3ThreeStages] log6 左眼外参三阶段变换 ══════════════════════════════╗
│ 理论说明:
│   ARKit extrinsics = View 矩阵  E = [Rᵀ | −Rᵀ·t]
│   ∴ E.col3 = −Rᵀ·t  （≠ 相机位置，需经求逆才能还原）
│   R_x(π) 作用：OpenCV（+Y↓ +Z↑前）→ RealityKit（+Y↑ +Z↑后），Y/Z 同时取反
│   最终 Pose = (R_x(π)·E)⁻¹  col3 才是相机在设备局部的真实位置
├─ 阶段1  E.col3（原始 View 矩阵平移分量 −Rᵀ·t）──────────────────────────
│   x = \(f(c1.x))   ← 预期  0.02437
│   y = \(f(c1.y))   ← 预期 -0.02011  (负号 = −Rᵀ·t 的 y 分量)
│   z = \(f(c1.z))   ← 预期 -0.05793  (负号 = −Rᵀ·t 的 z 分量)
│   注意：这不是相机位置！直接使用会导致 IPD 计算错误（~4.89 cm ❌）
""")

        #expect(abs(c1.x -  0.02437) < 1e-4)
        #expect(abs(c1.y - -0.02011) < 1e-4)
        #expect(abs(c1.z - -0.05793) < 1e-4)

        // ── 阶段2: R_x(π)·E 的 col3 ──────────────────────────────────
        let rotated = Rx * E
        let c2      = rotated.columns.3
        let diffY   = c2.y - c1.y  // 应为 +0.04022（Y 翻转）
        let diffZ   = c2.z - c1.z  // 应为 +0.11586（Z 翻转）
        print("""
├─ 阶段2  R_x(π)·E  col3（Y/Z 翻转后，仍是 View 矩阵平移分量）──────────────
│   x = \(f(c2.x))   ← 预期  0.02437  (X 轴不受 R_x(π) 影响)
│   y = \(f(c2.y))   ← 预期  0.02011  (Y 取反 ✓，Δy=\(Self.f5(diffY)))
│   z = \(f(c2.z))   ← 预期  0.05793  (Z 取反 ✓，Δz=\(Self.f5(diffZ)))
│   R_x(π) 旋转矩阵（行主序展示）:
│     [1,  0,  0]
│     [0, -1,  0]    ← col1 取反 → y 分量取反
│     [0,  0, -1]    ← col2 取反 → z 分量取反
""")

        #expect(abs(c2.x -  0.02437) < 1e-4)
        #expect(abs(c2.y -  0.02011) < 1e-4)  // Y 取反 ✓
        #expect(abs(c2.z -  0.05793) < 1e-4)  // Z 取反 ✓

        // ── 阶段3: Pose.col3（真实相机位置）──────────────────────────
        let pose = try SingleEyeExtrinsic.getViewTransform(from: E)
        let c3   = pose.matrixDouble.columns.3
        let poseM = pose.matrixDouble
        let rot   = poseM.rotationMatrix
        print("""
├─ 阶段3  (R_x(π)·E)⁻¹ = Pose 矩阵  col3（相机在设备局部的真实位置）──────────
│   x = \(f(c3.x))   ← 预期 -0.03162849
│   y = \(f(c3.y))   ← 预期 -0.02516594
│   z = \(f(c3.z))   ← 预期 -0.05215478
│   解读：相机在设备坐标系中，位于设备中心左前下方约 5.2 cm 处 ✅
├─ 完整 Pose 矩阵（行主序展示）──────────────────────────────────────────────
│   R部分:
│     [\(f(rot.columns.0.x)), \(f(rot.columns.1.x)), \(f(rot.columns.2.x))]
│     [\(f(rot.columns.0.y)), \(f(rot.columns.1.y)), \(f(rot.columns.2.y))]
│     [\(f(rot.columns.0.z)), \(f(rot.columns.1.z)), \(f(rot.columns.2.z))]
│   t(col3):
│     [\(f(poseM.columns.3.x)), \(f(poseM.columns.3.y)), \(f(poseM.columns.3.z))]
│   det(Pose) = \(Self.f8(simd_determinant(poseM)))  ← 应为 1.0（刚性变换）
╚══════════════════════════════════════════════════════════════════════════╝
""")

        // 高精度: (−0.03162848600, −0.02516593965, −0.05215478092)
        #expect(abs(c3.x - -0.031628) < 1e-4)
        #expect(abs(c3.y - -0.025166) < 1e-4)
        #expect(abs(c3.z - -0.052155) < 1e-4)
    }

    /// IPD 核心验证（log6）
    /// 错误假设（E.col3 直接当位置）→ 4.89cm ❌
    /// 正确做法（getViewTransform 后取 Pose.col3）→ 6.37cm ✅
    @MainActor @Test("IPD: View假设→4.89cm ❌  Pose假设→6.37cm ✅  ·  log6")
    func ipdVerification() throws {
        let f = Self.f8

        // ── 错误: E.col3 直接当位置 ────────────────────────────────────
        let eL     = leftEyeE_log6.columns.3.xyz
        let eR     = rightEyeE_log6.columns.3.xyz
        let delta  = eL - eR
        let ipdWrong = simd_length(delta)

        print("""

╔═ [ipdVerification] 瞳距(IPD)两种算法对比 · log6 ═══════════════════════════╗
│ 背景：人眼 IPD 正常范围 5~8 cm（典型值 ~6.3 cm）
│
├─ ❌ 错误做法：直接用 E.col3 当相机位置（col3 = −Rᵀ·t，不是位置）────────────
│   左眼 E.col3  = (\(f(eL.x)), \(f(eL.y)), \(f(eL.z)))
│   右眼 E.col3  = (\(f(eR.x)), \(f(eR.y)), \(f(eR.z)))
│   差向量 ΔE    = (\(f(delta.x)), \(f(delta.y)), \(f(delta.z)))
│   ‖ΔE‖ = \(f(ipdWrong)) m = \(String(format: "%.2f", ipdWrong * 100)) cm  ← 明显偏小，不在正常范围内 ❌
""")

        #expect(abs(ipdWrong - 0.0489) < 0.001)
        #expect(ipdWrong < 0.055)  // 远小于正常值，确认这是错误结果

        // ── 正确: getViewTransform 后取 Pose.col3 ──────────────────────
        let tL = try SingleEyeExtrinsic.getViewTransform(from: leftEyeE_log6).matrixDouble.columns.3.xyz
        let tR = try SingleEyeExtrinsic.getViewTransform(from: rightEyeE_log6).matrixDouble.columns.3.xyz
        let deltaT      = tL - tR
        let ipdCorrect  = simd_length(deltaT)
        let improvement = (ipdCorrect - ipdWrong) / ipdWrong * 100  // 提升百分比

        print("""
├─ ✅ 正确做法：getViewTransform → Pose 矩阵 → Pose.col3 = 真实相机位置─────────
│   左眼 Pose.col3 = (\(f(tL.x)), \(f(tL.y)), \(f(tL.z)))
│   右眼 Pose.col3 = (\(f(tR.x)), \(f(tR.y)), \(f(tR.z)))
│   差向量 Δt      = (\(f(deltaT.x)), \(f(deltaT.y)), \(f(deltaT.z)))
│   ‖Δt‖ = \(f(ipdCorrect)) m = \(String(format: "%.2f", ipdCorrect * 100)) cm  ← 正常 IPD ✅
│
├─ 误差分析 ─────────────────────────────────────────────────────────────────
│   错误 IPD  = \(String(format: "%.4f", ipdWrong)) m = \(String(format: "%.2f", ipdWrong  * 100)) cm ❌
│   正确 IPD  = \(String(format: "%.4f", ipdCorrect)) m = \(String(format: "%.2f", ipdCorrect * 100)) cm ✅
│   相差       = \(String(format: "%.2f", improvement))%（直接用 E.col3 导致 IPD 严重低估）
│   原因：E.col3 = −Rᵀ·t，其模长 ≠ 相机到原点的距离，两眼差值也 ≠ IPD
╚══════════════════════════════════════════════════════════════════════════╝
""")

        // log6 实测: IPD = 0.0637m，人眼正常范围 5~8cm
        #expect(abs(ipdCorrect - 0.0637) < 0.001)
        #expect(ipdCorrect > 0.055 && ipdCorrect < 0.080)
    }

    /// Pose 是刚性变换（log6）
    @MainActor @Test("输出是刚性变换: det=1, R·Rᵀ=I")
    func outputIsRigidTransform() throws {
        let M    = try SingleEyeExtrinsic.getViewTransform(from: leftEyeE_log6).matrixDouble
        let R    = M.rotationMatrix
        let Rt   = R.transpose
        let RRt  = R * Rt
        let det  = simd_determinant(M)
        let f    = Self.f8
        let f5   = Self.f5

        // 提取 R·Rᵀ 各元素（列主序：[col][row]）
        let diag0 = RRt[0][0], diag1 = RRt[1][1], diag2 = RRt[2][2]
        let off01 = RRt[1][0], off02 = RRt[2][0], off12 = RRt[2][1]
        let off10 = RRt[0][1], off20 = RRt[0][2], off21 = RRt[1][2]

        print("""

╔═ [outputIsRigidTransform] Pose 矩阵刚性变换验证 · log6 左眼 ════════════════╗
│ 刚性变换 = 纯旋转 + 纯平移，无缩放/剪切，约束：det(R)=1  且  R·Rᵀ=I
│
├─ 行列式验证 ───────────────────────────────────────────────────────────────
│   det(Pose) = \(f(det))
│   |det − 1| = \(f(abs(det - 1)))   ← 阈值 1e-5，应几乎为零 ✅
│
├─ R·Rᵀ 矩阵（应为单位矩阵）────────────────────────────────────────────────
│   列主序存储，[col][row]，以行主序展示便于阅读：
│   行0: [\(f5(RRt[0][0])), \(f5(RRt[1][0])), \(f5(RRt[2][0]))]
│   行1: [\(f5(RRt[0][1])), \(f5(RRt[1][1])), \(f5(RRt[2][1]))]
│   行2: [\(f5(RRt[0][2])), \(f5(RRt[1][2])), \(f5(RRt[2][2]))]
│
├─ 对角线元素（应为 1.0）────────────────────────────────────────────────────
│   RRt[0][0] = \(f(diag0))   误差 = \(f(abs(diag0 - 1)))  \(abs(diag0 - 1) < 1e-5 ? "✅" : "❌")
│   RRt[1][1] = \(f(diag1))   误差 = \(f(abs(diag1 - 1)))  \(abs(diag1 - 1) < 1e-5 ? "✅" : "❌")
│   RRt[2][2] = \(f(diag2))   误差 = \(f(abs(diag2 - 1)))  \(abs(diag2 - 1) < 1e-5 ? "✅" : "❌")
│
├─ 非对角线元素（应为 0.0）──────────────────────────────────────────────────
│   RRt[1][0] = \(f(off01))   |val| = \(f(abs(off01)))  \(abs(off01) < 1e-5 ? "✅" : "❌")
│   RRt[2][0] = \(f(off02))   |val| = \(f(abs(off02)))  \(abs(off02) < 1e-5 ? "✅" : "❌")
│   RRt[2][1] = \(f(off12))   |val| = \(f(abs(off12)))  \(abs(off12) < 1e-5 ? "✅" : "❌")
│   RRt[0][1] = \(f(off10))   |val| = \(f(abs(off10)))  \(abs(off10) < 1e-5 ? "✅" : "❌")
│   RRt[0][2] = \(f(off20))   |val| = \(f(abs(off20)))  \(abs(off20) < 1e-5 ? "✅" : "❌")
│   RRt[1][2] = \(f(off21))   |val| = \(f(abs(off21)))  \(abs(off21) < 1e-5 ? "✅" : "❌")
│
├─ R 矩阵（列主序，行主序展示）───────────────────────────────────────────────
│   行0: [\(f5(R.columns.0.x)), \(f5(R.columns.1.x)), \(f5(R.columns.2.x))]
│   行1: [\(f5(R.columns.0.y)), \(f5(R.columns.1.y)), \(f5(R.columns.2.y))]
│   行2: [\(f5(R.columns.0.z)), \(f5(R.columns.1.z)), \(f5(R.columns.2.z))]
│
├─ Rᵀ 矩阵（R 的转置）───────────────────────────────────────────────────────
│   行0: [\(f5(Rt.columns.0.x)), \(f5(Rt.columns.1.x)), \(f5(Rt.columns.2.x))]
│   行1: [\(f5(Rt.columns.0.y)), \(f5(Rt.columns.1.y)), \(f5(Rt.columns.2.y))]
│   行2: [\(f5(Rt.columns.0.z)), \(f5(Rt.columns.1.z)), \(f5(Rt.columns.2.z))]
╚══════════════════════════════════════════════════════════════════════════╝
""")

        #expect(abs(det - 1.0) < 1e-5)  // det = 1
        // 对角线 = 1
        #expect(abs(diag0 - 1) < 1e-5)
        #expect(abs(diag1 - 1) < 1e-5)
        #expect(abs(diag2 - 1) < 1e-5)
        // 非对角线 = 0（列主序：[col][row]）
        #expect(abs(off01) < 1e-5)
        #expect(abs(off02) < 1e-5)
        #expect(abs(off12) < 1e-5)
    }
}

// MARK: - Suite 3：WorldToCamera 正投影

@Suite("世界→相机投影 WorldToCamera")
struct WorldToCameraTests {

    /// 正前方点 → 图像中心（合成数据）
    /// (0,0,−10) → normalizedX=0, normalizedY=0 → pixel(320, 240)
    @Test("正前方 (0,0,−10) → 图像中心 (320,240)")
    func centerPoint() throws {
        let p = try WorldToCamera(perspectiveCameraData: syntheticData())
            .worldPointToCameraPixel(worldPoint: Point3D(x: 0, y: 0, z: -10), eye: .left)
        #expect(abs(p.x - 320) < 1e-6)
        #expect(abs(p.y - 240) < 1e-6)
    }

    /// 偏移点验证 X/Y 方向约定（合成数据，fy=100, cx=320, cy=240, 640×480）
    /// (1,0,−1): normalizedX=1/1=1, pixelX=1×100+320=420, imageY=480−240=240
    /// (0,1,−1): normalizedY=1/1=1, pixelY(翻转前)=340, imageY=480−340=140
    @Test("偏移: (1,0,−1)→(420,240)  (0,1,−1)→(320,140)")
    func offsetPoints() throws {
        let w2c = WorldToCamera(perspectiveCameraData: syntheticData())

        let pR = try w2c.worldPointToCameraPixel(worldPoint: Point3D(x: 1, y: 0, z: -1), eye: .left)
        #expect(abs(pR.x - 420) < 1e-6)
        #expect(abs(pR.y - 240) < 1e-6)

        let pU = try w2c.worldPointToCameraPixel(worldPoint: Point3D(x: 0, y: 1, z: -1), eye: .left)
        #expect(abs(pU.x - 320) < 1e-6)
        #expect(abs(pU.y - 140) < 1e-6)  // 世界Y+（上）→ 图像Y减小 ✓
    }

    /// Y 轴方向符合左上角原点约定
    @Test("Y轴约定: 世界Y+ → 图像Y减小（左上角为原点）")
    func yAxisConvention() throws {
        let w2c = WorldToCamera(perspectiveCameraData: syntheticData())
        let pC = try w2c.worldPointToCameraPixel(worldPoint: Point3D(x: 0, y:  0, z: -1), eye: .left)
        let pU = try w2c.worldPointToCameraPixel(worldPoint: Point3D(x: 0, y:  1, z: -1), eye: .left)
        let pD = try w2c.worldPointToCameraPixel(worldPoint: Point3D(x: 0, y: -1, z: -1), eye: .left)
        #expect(pU.y < pC.y)  // 世界Y+（上）→ 图像Y减小 ✓
        #expect(pD.y > pC.y)  // 世界Y−（下）→ 图像Y增大 ✓
    }

    /// 相机后方点应抛出错误
    @Test("z>0（相机后方）→ pointNotInFront 错误")
    func pointBehindCamera() {
        let w2c = WorldToCamera(perspectiveCameraData: syntheticData())
        #expect(throws: WorldToCamera.WorldToCameraError.self) {
            try w2c.worldPointToCameraPixel(worldPoint: Point3D(x: 0, y: 0, z: 1), eye: .left)
        }
    }
}

// MARK: - Suite 4：CameraToWorld 反投影

@Suite("相机→世界射线 CameraToWorld")
struct CameraToWorldTests {

    /// 图像中心 → 朝 −Z 的射线（合成 identity 相机）
    @Test("图像中心 (320,240) → 原点出发，朝 (0,0,−1) 方向")
    func centerPixelForwardRay() async {
        let ray = await CameraToWorld(perspectiveCameraData: syntheticData())
            .cameraPointToWorldRay(cameraPoint: Point2D(x: 320, y: 240), eye: .left)

        // identity 相机在原点
        #expect(abs(ray.origin.x) < 1e-6)
        #expect(abs(ray.origin.y) < 1e-6)
        #expect(abs(ray.origin.z) < 1e-6)
        // 中心像素 → 朝正前方 (0, 0, −1)
        #expect(abs(ray.direction.x)           < 1e-6)
        #expect(abs(ray.direction.y)           < 1e-6)
        #expect(abs(ray.direction.z - (-1.0))  < 1e-6)
    }

    /// 反透视公式数值验证（log9，不依赖 cameraPose 旋转，纯数学）
    /// pixel(1008, 420) → Y翻转 → 659.663
    /// dir_x = (1008−960)/736.63 = 0.0652  dir_y = (659.663−540)/736.63 = 0.1624
    @Test("反透视: 像素(1008,420) → 相机空间方向(0.0652, 0.1624, −1)  ·  log9")
    func backProjectionFromLog9() {
        let (fx, _, cx, cy) = WorldToCamera.GetIntrinsics().restoreIntrinsics(
            simpleIntrinsic: simpleIntrinsic_log6,
            resolution: resolution_log6
        )
        let dirX = (1008.0             - cx) / fx  // (1008−960)/736.63 = 0.0652
        let dirY = (1080.0 - 420.337  - cy) / fx  // (659.663−540)/736.63 = 0.1624
        #expect(abs(dirX - 0.0652) < 1e-4)  // log9 实测 ✓
        #expect(abs(dirY - 0.1624) < 1e-4)  // log9 实测 ✓
    }
}

// MARK: - Suite 5：往返一致性

@Suite("往返一致性 WorldToCamera ↔ CameraToWorld")
struct RoundTripTests {

    /// 世界点经正投影→像素→反投影→射线，原世界点应精确落在射线上
    /// identity 相机：t = worldPoint.z / ray.direction.z 直接解出交点
    @Test(
        "世界点在射线上（往返误差 < 1e-5）",
        arguments: [
            Point3D(x:  0.5, y: -0.3, z:  -5.0),
            Point3D(x: -1.0, y:  1.0, z:  -3.0),
            Point3D(x:  0.0, y:  0.0, z:  -1.0),
            Point3D(x:  2.0, y: -2.0, z: -10.0)
        ]
    )
    func worldPointOnRay(worldPoint: Point3D) async throws {
        let data  = syntheticData()
        let pixel = try WorldToCamera(perspectiveCameraData: data)
            .worldPointToCameraPixel(worldPoint: worldPoint, eye: .left)
        let ray   = await CameraToWorld(perspectiveCameraData: data)
            .cameraPointToWorldRay(cameraPoint: pixel, eye: .left)

        // identity 相机原点在 (0,0,0)，t = worldPoint.z / dir.z
        let t = worldPoint.z / ray.direction.z
        let onRay = Point3D(
            x: ray.origin.x + t * ray.direction.x,
            y: ray.origin.y + t * ray.direction.y,
            z: ray.origin.z + t * ray.direction.z
        )
        #expect(abs(onRay.x - worldPoint.x) < 1e-5)
        #expect(abs(onRay.y - worldPoint.y) < 1e-5)
        #expect(abs(onRay.z - worldPoint.z) < 1e-5)
    }
}
