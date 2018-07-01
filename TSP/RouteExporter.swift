import Foundation

struct RouteExporter {
    
    let minX: Float
    let minY: Float
    let scale: Float
    
    init(route: Route, max: Int) {
        var points = route.points

        minX = points.min { $0.x < $1.x }!.x
        minY = points.min { $0.y < $1.y }!.y
        
        for i in points.indices {
            points[i] = Point(points[i].x - minX, points[i].y - minY)
        }
        
        let maxX = points.max { $0.x < $1.x }!.x
        let maxY = points.max { $0.y < $1.y }!.y
        
        let largestValue = maxX > maxY ? maxX : maxY
        scale = Float(max) / largestValue
    }
    
    func export(_ route: Route) -> [CGPoint] {
        return route.points.map { point -> CGPoint in
            let x = Int(((point.x - minX) * scale).rounded(.toNearestOrEven))
            let y = Int(((point.y - minY) * scale).rounded(.toNearestOrEven))
            return CGPoint(x: x, y: y)
        }
    }
    
}
