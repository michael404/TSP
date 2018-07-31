import Dispatch

struct Route: Equatable {
        
    var points: [Point]
    
    var distance: Float {
        guard points.count >= 2 else { return 0 }
        var result: Float = 0.0
        for i in points.indices.dropLast() {
            result += points[i].distance(to: points[i+1])
        }
        return result + points.last!.distance(to: points.first!)
    }
    
    init<C: Collection>(_ points: C) where C.Element == Point {
        assert(points.elementsAreUnique)
        self.points = Array(points)
    }
    
    init(nearestNeighborFrom unsortedPoints: [Point], startAt: Int = 0) {
        
        assert(unsortedPoints.elementsAreUnique)
        
        self.points = unsortedPoints
        
        points.swapAt(startIndex, startAt)
        
        for (lastSortedIndex, firstUnsortedIndex) in zip(indices, indices.dropFirst()) {
            
            var nearestPointIndex = -1
            var nearestPointDistance = Float.infinity
            
            for indexCandidate in firstUnsortedIndex..<endIndex {
                let distanceCandidate = points[lastSortedIndex].distanceSquared(to: points[indexCandidate])
                if distanceCandidate < nearestPointDistance {
                    nearestPointIndex = indexCandidate
                    nearestPointDistance = distanceCandidate
                }
            }
            
            points.swapAt(firstUnsortedIndex, nearestPointIndex)
        }
    }
    
    init(nearestNeighborWithOptimalStartingPositionFrom unsortedPoints: [Point]) {
        self.points = unsortedPoints
        let serialQueue = DispatchQueue(label: "TSP", qos: .userInitiated)
        var lowestDistance = Float.infinity
        DispatchQueue.concurrentPerform(iterations: points.count) { i in
            let newRoute = Route(nearestNeighborFrom: unsortedPoints, startAt: i)
            let newRouteDistance = newRoute.distance
            serialQueue.sync {
                if newRouteDistance < lowestDistance {
                    self = newRoute
                    lowestDistance = newRouteDistance
                }
            }
        }
    }
    
    init(bruteforceOptimalRouteFrom unsortedPoints: [Point]) {
        var result: [Point] = []
        var distanceOfResult = Float.infinity
        var points = unsortedPoints
        Route.bruteforceOptimalRoute(from: &points, startAt: 0, result: &result, distanceOfResult: &distanceOfResult)
        self.points = result
    }
    
    private static func bruteforceOptimalRoute(
        from points: inout [Point],
        startAt: Int,
        result: inout [Point],
        distanceOfResult: inout Float
        ) {
        if startAt == points.endIndex {
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

extension Route: MutableCollection, RandomAccessCollection {
    
    subscript(i: Int) -> Point {
        get { return points[i] }
        set { points[i] = newValue }
    }
    
    var startIndex: Int { return points.startIndex }
    
    var endIndex: Int { return points.endIndex }
    
}

