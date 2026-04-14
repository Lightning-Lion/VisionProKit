import os
import Spatial
import RealityKit
import simd
import Foundation

// MARK: - ScreenIntersectionChecker
/// 屏幕相交检测器
/// 检测两个3D四边形屏幕是否相交
nonisolated
public struct ScreenIntersectionChecker {
    
    public struct IntersectionResult: Sendable {
        public let intersects: Bool
        public let type: String
        public let info: String
    }
    
    public struct ScreenData: Sendable {
        public let center: SIMD3<Double>
        public let rotation: simd_double3x3
        public let width: Double
        public let height: Double
        
        public init(pose: Transform, size: Size2D) {
            self.center = SIMD3<Double>(pose.translationPoint3D.x, pose.translationPoint3D.y, pose.translationPoint3D.z)
            self.rotation = pose.matrixDouble.rotationMatrix
            self.width = size.width
            self.height = size.height
        }
    }
    
    public static func checkIntersection(
        screen1: ScreenData,
        screen2: ScreenData,
        tolerance: Double = 1e-6,
        debug: Bool = false
    ) -> IntersectionResult {
        let corners1 = createScreenCorners(screen: screen1)
        let corners2 = createScreenCorners(screen: screen2)
        return polygonsIntersection3D(corners1: corners1, corners2: corners2, tolerance: tolerance, debug: debug)
    }
    
    private static func createScreenCorners(screen: ScreenData) -> [SIMD3<Double>] {
        let halfW = screen.width / 2.0
        let halfH = screen.height / 2.0
        let cornersLocal = [
            SIMD3<Double>(-halfW, -halfH, 0),
            SIMD3<Double>(halfW, -halfH, 0),
            SIMD3<Double>(halfW, halfH, 0),
            SIMD3<Double>(-halfW, halfH, 0)
        ]
        return cornersLocal.map { corner in
            let worldOffset = corner.x * screen.rotation.columns.0 + corner.y * screen.rotation.columns.1 + corner.z * screen.rotation.columns.2
            return worldOffset + screen.center
        }
    }
    
    private static func getPlaneFromCorners(_ corners: [SIMD3<Double>]) -> (normal: SIMD3<Double>, d: Double) {
        let v1 = corners[1] - corners[0]
        let v2 = corners[2] - corners[0]
        var normal = simd_cross(v1, v2)
        normal = simd_normalize(normal)
        let d = -simd_dot(normal, corners[0])
        return (normal, d)
    }
    
    private static func polygonsIntersection3D(
        corners1: [SIMD3<Double>],
        corners2: [SIMD3<Double>],
        tolerance: Double,
        debug: Bool = false
    ) -> IntersectionResult {
        let (normal1, d1) = getPlaneFromCorners(corners1)
        let (normal2, d2) = getPlaneFromCorners(corners2)
        
        let crossNormals = simd_cross(normal1, normal2)
        let crossNormalsLength = simd_length(crossNormals)
        let planesParallel = crossNormalsLength < tolerance
        
        if planesParallel {
            let coplanarCheck = simd_dot(normal1, corners2[0]) + d1
            if abs(coplanarCheck) > tolerance {
                return IntersectionResult(intersects: false, type: "平行不共面", info: "两个屏幕平面平行但不重合，不相交")
            }
            return handleCoplanarCase(corners1: corners1, corners2: corners2, normal: normal1, tolerance: tolerance)
        }
        
        return handleNonParallelCase(corners1: corners1, corners2: corners2, normal1: normal1, d1: d1, normal2: normal2, d2: d2, tolerance: tolerance)
    }
    
    private static func handleCoplanarCase(
        corners1: [SIMD3<Double>],
        corners2: [SIMD3<Double>],
        normal: SIMD3<Double>,
        tolerance: Double
    ) -> IntersectionResult {
        let (coords1, u1, _, center1) = projectTo2D(corners: corners1, normal: normal)
        let (coords2, _, _, _) = projectTo2D(corners: corners2, normal: normal)
        
        var intersections: [SIMD3<Double>] = []
        
        for (i, p) in coords1.enumerated() {
            if pointInPolygon2D(point: p, polygon: coords2, tolerance: tolerance) {
                intersections.append(corners1[i])
            }
        }
        for (i, p) in coords2.enumerated() {
            if pointInPolygon2D(point: p, polygon: coords1, tolerance: tolerance) {
                intersections.append(corners2[i])
            }
        }
        
        for i in 0..<4 {
            for j in 0..<4 {
                if let pt = segmentIntersection2D(a1: coords1[i], a2: coords1[(i+1)%4], b1: coords2[j], b2: coords2[(j+1)%4], tolerance: tolerance) {
                    let pt3D = center1 + pt.x * u1 + pt.y * u1 // simplified
                    intersections.append(pt3D)
                }
            }
        }
        
        let uniqueIntersections = deduplicatePoints(intersections, tolerance: tolerance)
        
        if uniqueIntersections.isEmpty {
            return IntersectionResult(intersects: false, type: "共面不相交", info: "两个屏幕共面但不相交")
        }
        return IntersectionResult(intersects: true, type: "共面相交", info: "两个屏幕共面且相交，共 \(uniqueIntersections.count) 个交点")
    }
    
    private static func handleNonParallelCase(
        corners1: [SIMD3<Double>],
        corners2: [SIMD3<Double>],
        normal1: SIMD3<Double>,
        d1: Double,
        normal2: SIMD3<Double>,
        d2: Double,
        tolerance: Double
    ) -> IntersectionResult {
        var lineDir = simd_cross(normal1, normal2)
        lineDir = simd_normalize(lineDir)
        
        let A_row_major = simd_double3x3(
            SIMD3<Double>(normal1.x, normal2.x, lineDir.x),
            SIMD3<Double>(normal1.y, normal2.y, lineDir.y),
            SIMD3<Double>(normal1.z, normal2.z, lineDir.z)
        )
        let b = SIMD3<Double>(-d1, -d2, 0)
        
        guard let linePoint = solveLinearSystem(A: A_row_major, b: b) else {
            return IntersectionResult(intersects: false, type: "计算错误", info: "无法计算平面交线")
        }
        
        var intersections: [(point: SIMD3<Double>, type: Int)] = []
        
        var lineQuad1Intersections: [(point: SIMD3<Double>, t: Double)] = []
        for i in 0..<4 {
            let edgeStart = corners1[i]
            let edgeEnd = corners1[(i+1)%4]
            let edgeDir = edgeEnd - edgeStart
            if let ts = solveLeastSquares(lineDir: lineDir, edgeDir: edgeDir, b: edgeStart - linePoint) {
                let t = ts.x; let s = ts.y
                if -tolerance <= s && s <= 1.0 + tolerance {
                    lineQuad1Intersections.append((linePoint + t * lineDir, t))
                }
            }
        }
        
        var lineQuad2Intersections: [(point: SIMD3<Double>, t: Double)] = []
        for i in 0..<4 {
            let edgeStart = corners2[i]
            let edgeEnd = corners2[(i+1)%4]
            let edgeDir = edgeEnd - edgeStart
            if let ts = solveLeastSquares(lineDir: lineDir, edgeDir: edgeDir, b: edgeStart - linePoint) {
                let t = ts.x; let s = ts.y
                if -tolerance <= s && s <= 1.0 + tolerance {
                    lineQuad2Intersections.append((linePoint + t * lineDir, t))
                }
            }
        }
        
        if lineQuad1Intersections.count >= 2 && lineQuad2Intersections.count >= 2 {
            let t1Values = lineQuad1Intersections.map { $0.t }
            let t2Values = lineQuad2Intersections.map { $0.t }
            let t1Min = t1Values.min() ?? 0; let t1Max = t1Values.max() ?? 0
            let t2Min = t2Values.min() ?? 0; let t2Max = t2Values.max() ?? 0
            let tOverlapMin = max(t1Min, t2Min)
            let tOverlapMax = min(t1Max, t2Max)
            if tOverlapMin <= tOverlapMax + tolerance {
                let pStart = linePoint + tOverlapMin * lineDir
                let pEnd = linePoint + tOverlapMax * lineDir
                if simd_length(pEnd - pStart) < tolerance {
                    intersections.append((pStart, 3))
                } else {
                    intersections.append((pStart, 3))
                    intersections.append((pEnd, 3))
                }
            }
        }
        
        for i in 0..<4 {
            for j in 0..<4 {
                if let pt = segmentIntersection3D(a1: corners1[i], a2: corners1[(i+1)%4], b1: corners2[j], b2: corners2[(j+1)%4], tolerance: tolerance) {
                    intersections.append((pt, 0))
                }
            }
        }
        
        let uniqueIntersections = intersections.filter { item in
            !intersections.contains { other in
                simd_length(item.point - other.point) < tolerance && item.point != other.point
            }
        }
        // Simple deduplication
        var unique: [(point: SIMD3<Double>, type: Int)] = []
        for item in intersections {
            if !unique.contains(where: { simd_length($0.point - item.point) < tolerance }) {
                unique.append(item)
            }
        }
        
        if unique.isEmpty {
            return IntersectionResult(intersects: false, type: "不相交", info: "两个屏幕平面相交，但四边形不相交")
        }
        if unique.count == 1 {
            return IntersectionResult(intersects: true, type: "交于一点", info: "两个屏幕交于一个点")
        }
        if unique.count == 2 {
            return IntersectionResult(intersects: true, type: "交于线段", info: "两个屏幕交于一条线段")
        }
        return IntersectionResult(intersects: true, type: "多边形相交", info: "两个屏幕相交形成多边形，共 \(unique.count) 个交点")
    }
    
    // MARK: - Helper functions
    
    private static func projectTo2D(corners: [SIMD3<Double>], normal: SIMD3<Double>) -> (coords: [SIMD2<Double>], u: SIMD3<Double>, v: SIMD3<Double>, center: SIMD3<Double>) {
        let u: SIMD3<Double> = abs(normal.z) < 0.9 ? simd_normalize(simd_cross(normal, SIMD3<Double>(0, 0, 1))) : simd_normalize(simd_cross(normal, SIMD3<Double>(0, 1, 0)))
        let v = simd_normalize(simd_cross(normal, u))
        let center = corners.reduce(SIMD3<Double>(0, 0, 0), +) / Double(corners.count)
        let coords = corners.map { p -> SIMD2<Double> in
            let rel = p - center
            return SIMD2<Double>(simd_dot(rel, u), simd_dot(rel, v))
        }
        return (coords, u, v, center)
    }
    
    private static func pointInPolygon2D(point: SIMD2<Double>, polygon: [SIMD2<Double>], tolerance: Double) -> Bool {
        let x = point.x; let y = point.y; let n = polygon.count
        var inside = false
        for i in 0..<n {
            let x1 = polygon[i].x; let y1 = polygon[i].y
            let x2 = polygon[(i + 1) % n].x; let y2 = polygon[(i + 1) % n].y
            if abs((y2 - y1) * (x - x1) - (x2 - x1) * (y - y1)) < tolerance {
                if min(x1, x2) - tolerance <= x && x <= max(x1, x2) + tolerance && min(y1, y2) - tolerance <= y && y <= max(y1, y2) + tolerance {
                    return true
                }
            }
            if (y1 > y) != (y2 > y) {
                let xinters = (y - y1) * (x2 - x1) / (y2 - y1) + x1
                if xinters > x - tolerance { inside = !inside }
            }
        }
        return inside
    }
    
    private static func segmentIntersection2D(a1: SIMD2<Double>, a2: SIMD2<Double>, b1: SIMD2<Double>, b2: SIMD2<Double>, tolerance: Double) -> SIMD2<Double>? {
        let denom = (a1.x - a2.x) * (b1.y - b2.y) - (a1.y - a2.y) * (b1.x - b2.x)
        if abs(denom) < tolerance { return nil }
        let t = ((a1.x - b1.x) * (b1.y - b2.y) - (a1.y - b1.y) * (b1.x - b2.x)) / denom
        let u = -((a1.x - a2.x) * (a1.y - b1.y) - (a1.y - a2.y) * (a1.x - b1.x)) / denom
        if -tolerance <= t && t <= 1.0 + tolerance && -tolerance <= u && u <= 1.0 + tolerance {
            return SIMD2<Double>(a1.x + t * (a2.x - a1.x), a1.y + t * (a2.y - a1.y))
        }
        return nil
    }
    
    private static func segmentIntersection3D(a1: SIMD3<Double>, a2: SIMD3<Double>, b1: SIMD3<Double>, b2: SIMD3<Double>, tolerance: Double) -> SIMD3<Double>? {
        let da = a2 - a1; let db = b2 - b1; let dc = b1 - a1
        let crossDaDb = simd_cross(da, db)
        let denom = simd_dot(crossDaDb, crossDaDb)
        if denom < tolerance { return nil }
        let t = simd_dot(simd_cross(dc, db), crossDaDb) / denom
        let s = simd_dot(simd_cross(dc, da), crossDaDb) / denom
        if t < -tolerance || t > 1.0 + tolerance || s < -tolerance || s > 1.0 + tolerance { return nil }
        let p1 = a1 + t * da; let p2 = b1 + s * db
        if simd_length(p1 - p2) > tolerance { return nil }
        return (p1 + p2) / 2.0
    }
    
    private static func deduplicatePoints(_ points: [SIMD3<Double>], tolerance: Double) -> [SIMD3<Double>] {
        var unique: [SIMD3<Double>] = []
        for p in points {
            if !unique.contains(where: { simd_length($0 - p) < tolerance }) { unique.append(p) }
        }
        return unique
    }
    
    private static func solveLinearSystem(A: simd_double3x3, b: SIMD3<Double>) -> SIMD3<Double>? {
        let det = A.determinant
        if abs(det) < 1e-10 { return nil }
        return A.inverse * b
    }
    
    private static func solveLeastSquares(lineDir: SIMD3<Double>, edgeDir: SIMD3<Double>, b: SIMD3<Double>) -> SIMD2<Double>? {
        let a11 = simd_dot(lineDir, lineDir); let a12 = -simd_dot(lineDir, edgeDir)
        let a21 = -simd_dot(edgeDir, lineDir); let a22 = simd_dot(edgeDir, edgeDir)
        let det = a11 * a22 - a12 * a21
        if abs(det) < 1e-10 { return nil }
        let b1 = simd_dot(lineDir, b); let b2 = -simd_dot(edgeDir, b)
        let t = (a22 * b1 - a12 * b2) / det
        let s = (a11 * b2 - a21 * b1) / det
        return SIMD2<Double>(t, s)
    }
}
