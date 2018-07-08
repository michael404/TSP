import simd

struct Point: Equatable {
    
    let _point: simd_float2
    
    var x: Float { return _point.x }
    var y: Float { return _point.y }
    
    init(_ x: Float, _ y: Float) {
        self._point = simd_make_float2(x, y)
    }
    
}

extension Point: CustomStringConvertible {
    var description: String {
        return "(\(_point.x), \(_point.y))"
    }
    
    
}

extension Point: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(_point.x)
        hasher.combine(_point.y)
    }
}
