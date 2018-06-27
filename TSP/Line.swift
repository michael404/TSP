struct Line {
    let p1, p2: Point
    
    init(_ p1: Point, _ p2: Point) {
        self.p1 = p1
        self.p2 = p2
    }
    
    var distance: Float {
        let distanceX = p2.x - p1.x
        let distanceY = p2.y - p1.y
        return (distanceX * distanceX + distanceY * distanceY).squareRoot()
    }
}

extension Line: Equatable {
    static func ==(lhs: Line, rhs: Line) -> Bool {
        return (lhs.p1 == rhs.p1 && lhs.p2 == rhs.p2)
            || (lhs.p1 == rhs.p2 && lhs.p2 == rhs.p1)
    }
}

extension Line: Hashable {
    var hashValue: Int {
        return p1.hashValue ^ p2.hashValue
    }
}
