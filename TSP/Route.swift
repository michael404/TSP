import Dispatch

struct Route {
        
    var points: [Point]
    
    var distance: Float {
        var result: Float = 0.0
        for i in points.indices.dropLast() {
            result += Line(points[i], points[i+1]).distance
        }
        let lastLine = Line(points.last!, points.first!)
        result += lastLine.distance
        return result
    }
    
    init<C: Collection>(_ points: C) where C.Element == Point {
        assert(points.elementsAreUnique)
        self.points = Array(points)
    }
    
    init(nearestNeighborFrom points: [Point], startAt: Int) {
        assert(points.elementsAreUnique)
        var points = points
        points.sortBasedOnMinimumDistanceToLastElement(startAt: startAt) { Line($0, $1).distance }
        self.points = points
    }
    
    init(nearestNeighborWithOptimalStartingPosition points: [Point]) {
        var optimalRoute = Route(nearestNeighborFrom: points, startAt: 0)
        for start in 1..<points.endIndex {
            let newRoute = Route(nearestNeighborFrom: points, startAt: start)
            if newRoute.distance < optimalRoute.distance {
                optimalRoute = newRoute
            }
        }
        self = optimalRoute
    }
    
    init(concurrentRandomNearestNeighborWithOptimalStartingPosition points: [Point]) {
        var optimalRoute = Route(points)
        let serialQueue = DispatchQueue(label: "TSPEvolution", qos: .userInitiated)
        let iValues = (0..<points.count)
        DispatchQueue.concurrentPerform(iterations: points.count) { i in
            let newRoute = Route(nearestNeighborFrom: points, startAt: iValues[i])
            serialQueue.sync {
                if newRoute.distance < optimalRoute.distance {
                    optimalRoute = newRoute
                }
            }
        }
        self = optimalRoute
    }
    
    init(bruteforceOptimalRouteFrom points: [Point]) {
        var result: [Point] = []
        var distanceOfResult = Float.infinity
        var points = points
        Route.bruteforceOptimalRoute(from: &points, startAt: 0, result: &result, distanceOfResult: &distanceOfResult)
        self.points = result
    }
    
    // TODO
    // init(concurrentBruteforceOptimalRouteFrom points: [Point]) { }
    
    private static func bruteforceOptimalRoute(from points: inout [Point], startAt: Int, result: inout [Point], distanceOfResult: inout Float) {
        assert(points.elementsAreUnique)
        guard startAt != points.endIndex else {
            let distanceOfCurrentRoute = Route(points).distance
            if distanceOfCurrentRoute < distanceOfResult {
                result = points
                distanceOfResult = distanceOfCurrentRoute
            }
            return
        }
        for index in points[startAt...].indices {
            points.swapAt(points.startIndex, index)
            bruteforceOptimalRoute(from: &points, startAt: startAt + 1, result: &result, distanceOfResult: &distanceOfResult)
            // Swap back
            points.swapAt(points.startIndex, index)
        }
    }

}

extension Route: Equatable {
    
    // Custom implemenation that ignores the `distance` property
    static func ==(lhs: Route, rhs: Route) -> Bool {
        return lhs.elementsEqual(rhs)
    }
    
}

extension Route: MutableCollection, RandomAccessCollection {
    
    subscript(i: Int) -> Point {
        get { return points[i] }
        set { points[i] = newValue }
    }
    
    var startIndex: Int { return points.startIndex }
    
    var endIndex: Int { return points.endIndex }
}

