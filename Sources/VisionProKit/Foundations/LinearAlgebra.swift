import Spatial
import RealityKit

// MARK: - PointAndVectorAndTransformConverter
/// 坐标变换与矩阵构造工具
/// 纯数学计算，可在任意actor中执行
nonisolated
public struct PointAndVectorAndTransformConverter {
    
    public static func worldToLocal(_ pointWorld: Point3D, head: Transform) -> Point3D {
        let pointWorldSIMD3Float = SIMD3<Float>(pointWorld.vector)
        let headFloat4x4 = head.matrix
        let pointLocalSIMD3Float = worldToLocalInner(pointWorldSIMD3Float, head: headFloat4x4)
        return Point3D(vector: SIMD3<Double>(pointLocalSIMD3Float))
    }
    
    private static func worldToLocalInner(_ pointWorld: simd_float3, head: simd_float4x4) -> simd_float3 {
        let inverseHead = simd_inverse(head)
        func convertPoint(_ worldPoint: simd_float3) -> simd_float3 {
            let homogeneousPoint = simd_float4(worldPoint.x, worldPoint.y, worldPoint.z, 1.0)
            let localHomogeneous = inverseHead * homogeneousPoint
            return simd_float3(localHomogeneous.x, localHomogeneous.y, localHomogeneous.z)
        }
        return convertPoint(pointWorld)
    }
    
    public static func worldToLocal(_ point1World: Point3D, _ point2World: Point3D, head: Transform) -> (Point3D, Point3D) {
        let point1Local = worldToLocal(point1World, head: head)
        let point2Local = worldToLocal(point2World, head: head)
        return (point1Local, point2Local)
    }
    
    public static func point3DToSIMD3Float(_ point3D: Point3D) -> SIMD3<Float> {
        SIMD3<Float>(point3D.vector)
    }
    
    public static func simd3FloatToPoint3D(_ simd3Float: SIMD3<Float>) -> Point3D {
        Point3D(SIMD3<Double>(simd3Float))
    }
    
    public static func vector3DToSIMD3Float(_ vector3D: Vector3D) -> SIMD3<Float> {
        SIMD3<Float>(vector3D.vector)
    }
    
    public static func localToWorld(local: Vector3D, head: Transform) -> Vector3D {
        var removeTranslationHead = head
        removeTranslationHead.translation = .zero
        return Vector3D(vector: SIMD3<Double>(
            Transform(matrix:
                removeTranslationHead.matrix * Transform(translation: SIMD3<Float>(local.vector)).matrix
            ).translation
        ))
    }
    
    public static func makeMatrixSimplifiedL1(xAxis: Vector3D, yAxis: Vector3D, zAxis: Vector3D, center: Point3D) -> Transform {
        return Transform(matrix: makeMatrixSimplified(xAxis: SIMD3<Float>(xAxis.vector), yAxis: SIMD3<Float>(yAxis.vector), zAxis: SIMD3<Float>(zAxis.vector), center: SIMD3<Float>(center.vector)))
    }
    
    private static func makeMatrixSimplified(xAxis: simd_float3, yAxis: simd_float3, zAxis: simd_float3, center: simd_float3) -> simd_float4x4 {
        simd_float4x4(rows: [
            SIMD4<Float>([xAxis.x, yAxis.x, zAxis.x, center.x]),
            SIMD4<Float>([xAxis.y, yAxis.y, zAxis.y, center.y]),
            SIMD4<Float>([xAxis.z, yAxis.z, zAxis.z, center.z]),
            SIMD4<Float>([0, 0, 0, 1])
        ])
    }
}
