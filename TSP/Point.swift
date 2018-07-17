import simd

struct Point: Equatable {
    
    private let _point: simd_float2
    
    var x: Float { return _point.x }
    var y: Float { return _point.y }
    
    init(_ x: Float, _ y: Float) {
        self._point = simd_make_float2(x, y)
    }
    
    @inline(__always)
    func distance(to other: Point) -> Float {
        return simd_distance(self._point, other._point)
    }
    
    @inline(__always)
    func distanceSquared(to other: Point) -> Float {
        return simd_distance_squared(self._point, other._point)
    }
    
}

extension Point: CustomStringConvertible {
    var description: String {
        return "(\(x), \(y))"
    }
    
    
}

extension Point: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
