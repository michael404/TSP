struct Point: Hashable {
    
    let x: Float
    let y: Float
    
    init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
    
}

extension Point: CustomStringConvertible {
    var description: String {
        return "(\(x), \(y))"
    }
    
    
}
