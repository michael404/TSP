import simd

struct Point: Equatable {
    
    private let _point: simd_double2
    
    var x: Double { return _point.x }
    var y: Double { return _point.y }
    
    init(_ x: Double, _ y: Double) {
        self._point = simd_make_double2(x, y)
    }
    
    func distance(to other: Point) -> Double {
        return simd_distance(self._point, other._point)
    }
    
    func distanceSquared(to other: Point) -> Double {
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
