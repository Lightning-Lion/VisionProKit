import os
import SwiftUI
import RealityKit

// MARK: - Quadrilateral2D
/// 二维四边形，左上角是原点
public struct Quadrilateral2D: Sendable {
    public let topLeft: CGPoint
    public let topRight: CGPoint
    public let bottomLeft: CGPoint
    public let bottomRight: CGPoint
    
    public init(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }
}

public extension Quadrilateral2D {
    init(rect: CGRect) {
        self.init(
            topLeft: CGPoint(x: rect.minX, y: rect.minY),
            topRight: CGPoint(x: rect.maxX, y: rect.minY),
            bottomLeft: CGPoint(x: rect.minX, y: rect.maxY),
            bottomRight: CGPoint(x: rect.maxX, y: rect.maxY)
        )
    }
    
    func toCoreImageCoordinates(in size: CGSize) -> Quadrilateral2DCoreImageCoordinates {
        Quadrilateral2DCoreImageCoordinates(
            topLeft: CGPoint(x: topLeft.x, y: size.height - topLeft.y),
            topRight: CGPoint(x: topRight.x, y: size.height - topRight.y),
            bottomLeft: CGPoint(x: bottomLeft.x, y: size.height - bottomLeft.y),
            bottomRight: CGPoint(x: bottomRight.x, y: size.height - bottomRight.y)
        )
    }
}

// MARK: - Quadrilateral2DCoreImageCoordinates
/// Core Image坐标系四边形，左下角是原点
public struct Quadrilateral2DCoreImageCoordinates: Sendable {
    public let topLeft: CGPoint
    public let topRight: CGPoint
    public let bottomLeft: CGPoint
    public let bottomRight: CGPoint
    
    public init(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }
}

public extension Quadrilateral2DCoreImageCoordinates {
    
    func intersects(with rect: CGRect) -> Bool {
        for point in [topLeft, topRight, bottomLeft, bottomRight] {
            if rect.contains(point) { return true }
        }
        let edges = [(topLeft, topRight), (topRight, bottomRight), (bottomRight, bottomLeft), (bottomLeft, topLeft)]
        let rectEdges = [
            (CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.minY)),
            (CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.maxY)),
            (CGPoint(x: rect.maxX, y: rect.maxY), CGPoint(x: rect.minX, y: rect.maxY)),
            (CGPoint(x: rect.minX, y: rect.maxY), CGPoint(x: rect.minX, y: rect.minY))
        ]
        for edge in edges {
            for rectEdge in rectEdges {
                if linesIntersect(edge.0, edge.1, rectEdge.0, rectEdge.1) { return true }
            }
        }
        return false
    }
    
    func isCompletelyInside(_ rect: CGRect) -> Bool {
        [topLeft, topRight, bottomLeft, bottomRight].allSatisfy { rect.contains($0) }
    }
    
    func boundingRect() -> CGRect {
        let xValues = [topLeft.x, topRight.x, bottomLeft.x, bottomRight.x]
        let yValues = [topLeft.y, topRight.y, bottomLeft.y, bottomRight.y]
        let minX = xValues.min() ?? 0; let maxX = xValues.max() ?? 0
        let minY = yValues.min() ?? 0; let maxY = yValues.max() ?? 0
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    private func linesIntersect(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint, _ p4: CGPoint) -> Bool {
        let denominator = (p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y)
        if denominator == 0 { return false }
        let ua = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)) / denominator
        let ub = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x)) / denominator
        return ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1
    }
    
    func translatedBy(dx: CGFloat, dy: CGFloat) -> Quadrilateral2DCoreImageCoordinates {
        Quadrilateral2DCoreImageCoordinates(
            topLeft: CGPoint(x: topLeft.x + dx, y: topLeft.y + dy),
            topRight: CGPoint(x: topRight.x + dx, y: topRight.y + dy),
            bottomLeft: CGPoint(x: bottomLeft.x + dx, y: bottomLeft.y + dy),
            bottomRight: CGPoint(x: bottomRight.x + dx, y: bottomRight.y + dy)
        )
    }
}
