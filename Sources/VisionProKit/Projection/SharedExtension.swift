import os
import SwiftUI
import Spatial
import ARKit
import RealityKit

// MARK: - Transform Extensions
/// Transform扩展 - Double精度支持

nonisolated
public extension Transform {
    var matrixDouble: simd_double4x4 {
        simd_double4x4(matrix)
    }
}

nonisolated
public extension Transform {
    var rotationDouble: simd_quatd {
        rotation.toDouble
    }
}

nonisolated
public extension Transform {
    var translationPoint3D: Point3D {
        Point3D(translation)
    }
}

nonisolated
public extension Transform {
    init(matrixDouble: simd_double4x4) {
        let floatMatrix = Self.convertToFloat4x4(from: matrixDouble)
        self.init(matrix: floatMatrix)
    }
    
    // 初始化仅旋转，无平移的Transform
    // 支持传入simd_quatd（Double精度），但Transform内部目前还是用Float存储的，只能降精度了
    init(rotationDouble: simd_quatd) {
        self.init(rotation: rotationDouble.toFloat)
    }
    
    init(rotation: simd_quatd, translation: SIMD3<Double>) {
        self.init(rotation: rotation.toFloat, translation: translation.toFloat)
    }
    
    private static func convertToFloat4x4(from doubleMatrix: double4x4) -> float4x4 {
        return float4x4(
            columns: (
                SIMD4<Float>(Float(doubleMatrix.columns.0.x), Float(doubleMatrix.columns.0.y), Float(doubleMatrix.columns.0.z), Float(doubleMatrix.columns.0.w)),
                SIMD4<Float>(Float(doubleMatrix.columns.1.x), Float(doubleMatrix.columns.1.y), Float(doubleMatrix.columns.1.z), Float(doubleMatrix.columns.1.w)),
                SIMD4<Float>(Float(doubleMatrix.columns.2.x), Float(doubleMatrix.columns.2.y), Float(doubleMatrix.columns.2.z), Float(doubleMatrix.columns.2.w)),
                SIMD4<Float>(Float(doubleMatrix.columns.3.x), Float(doubleMatrix.columns.3.y), Float(doubleMatrix.columns.3.z), Float(doubleMatrix.columns.3.w))
            )
        )
    }
}

// MARK: - simd_double4x4 Extensions
nonisolated
public extension simd_double4x4 {
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
    
    var xAxis: SIMD3<Double> { columns.0.xyz }
    var yAxis: SIMD3<Double> { columns.1.xyz }
    var zAxis: SIMD3<Double> { columns.2.xyz }
    
    var rotationMatrix: simd_double3x3 {
        simd_double3x3(columns: (xAxis, yAxis, zAxis))
    }
}

// MARK: - 使用Float和Double来表示2D点
nonisolated
public extension Point2D {
    var toSIMD2Double: SIMD2<Double> {
        SIMD2<Double>(x: x, y: y)
    }
}

nonisolated
public extension SIMD2<Double> {
    init(_ point2D: Point2D) {
        self.init(x: point2D.x, y: point2D.y)
    }
}

nonisolated
public extension Point2D {
    var toSIMD2Float: SIMD2<Float> {
        SIMD2<Float>(x: Float(x), y: Float(y))
    }
}

nonisolated
public extension SIMD2<Float> {
    init(_ point2D: Point2D) {
        self.init(x: Float(point2D.x), y: Float(point2D.y))
    }
}

// MARK: - 使用Float和Double来表示2D尺寸
nonisolated
public extension SIMD2<Float> {
    init(_ size2D: Size2D) {
        self.init(x: Float(size2D.width), y: Float(size2D.height))
    }
}

nonisolated
public extension SIMD4 {
    var xyz: SIMD3<Scalar> { .init(x, y, z) }
}

// MARK: - 使用Float和Double来表示旋转
nonisolated
public extension simd_quatd {
    var toFloat: simd_quatf {
        simd_quatf(ix: Float(imag.x), iy: Float(imag.y), iz: Float(imag.z), r: Float(real))
    }
}

nonisolated
public extension simd_quatf {
    init(fromDouble:simd_quatd) {
        let imag = fromDouble.imag
        let real = fromDouble.real
        self.init(ix: Float(imag.x), iy: Float(imag.y), iz: Float(imag.z), r: Float(real))
    }
}

nonisolated
public extension simd_quatf {
    var toDouble: simd_quatd {
        simd_quatd(ix: Double(imag.x), iy: Double(imag.y), iz: Double(imag.z), r: Double(real))
    }
}

nonisolated
public extension simd_quatd {
    init(fromFloat: simd_quatf) {
        let imag = fromFloat.imag
        let real = fromFloat.real
        self.init(ix: Double(imag.x), iy: Double(imag.y), iz: Double(imag.z), r: Double(real))
    }
}

// MARK: - 使用Float和Double来表示3D点和3D向量和3D缩放
nonisolated
public extension SIMD3<Double> {
    var toFloat: SIMD3<Float> {
        SIMD3<Float>(Float(x), Float(y), Float(z))
    }
}

nonisolated
public extension SIMD3<Float> {
    init(fromDouble: SIMD3<Double>) {
        self.init(x: Float(fromDouble.x), y: Float(fromDouble.y), z: Float(fromDouble.z))
    }
}

nonisolated
public extension SIMD3<Float> {
    var toDouble: SIMD3<Double> {
        SIMD3<Double>(Double(x), Double(y), Double(z))
    }
}

nonisolated
public extension SIMD3<Double> {
    init(fromFloat: SIMD3<Float>) {
        self.init(x: Double(fromFloat.x), y: Double(fromFloat.y), z: Double(fromFloat.z))
    }
}

// MARK: - 使用Float和Double来表示3D点（仅3D点）
nonisolated
public extension SIMD3<Float> {
    init(_ point3D: Point3D) {
        self.init(x: Float(point3D.x), y: Float(point3D.y), z: Float(point3D.z))
    }
}

nonisolated
public extension SIMD3<Double> {
    init(_ point3D: Point3D) {
        self.init(x: point3D.x, y: point3D.y, z: point3D.z)
    }
}
