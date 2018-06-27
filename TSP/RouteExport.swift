import Foundation

extension Route {
    
    //TODO: Test
    func export(max: Int) -> [CGPoint] {
        
        var result = points
        
        let smallestX = result.min { $0.x < $1.x }!.x
        let smallestY = result.min { $0.y < $1.y }!.y
        
        
        for i in result.indices {
            result[i] = Point(result[i].x - smallestX, result[i].y - smallestY)
        }
        
        let largestX = result.max { $0.x < $1.x }!.x
        let largestY = result.max { $0.y < $1.y }!.y

        
        let largestValue = largestX > largestY ? largestX : largestY
        
        
        let scale = Float(max) / largestValue
        return result.map { point -> CGPoint in
            let x = Int((point.x * scale).rounded(.toNearestOrEven))
            let y = Int((point.y * scale).rounded(.toNearestOrEven))
            return CGPoint(x: x, y: y)
        }
        
    }
    
}
