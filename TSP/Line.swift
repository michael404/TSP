import simd

struct Line {
    let p1, p2: simd_float2
    
    init(_ p1: Point, _ p2: Point) {
        self.p1 = p1._point
        self.p2 = p2._point
    }
    
    var distance: Float {
        @inline(__always)
        get {
            return simd_distance(p1, p2)
        }
    }
    
    var distanceSquared: Float {
        @inline(__always)
        get {
            return simd_distance_squared(p1, p2)
        }
    }
}
