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
    
    init(nearestNeighborFrom points: [Point], startAt: Int) {
        assert(points.elementsAreUnique)
        var points = points
        points.swapAt(points.startIndex, startAt)
        
        let threads = 4
        
        var buffer = Array<(Int, Float)>(repeating: (-1, Float.infinity), count: threads)
        
        for currentIndex in points.indices.dropLast() {
                        
            let indiciesToSearchThrough = points[(currentIndex + 2)...].indices
            
            // Find the point with the shortest distance accross in each thread
            indiciesToSearchThrough.performConcurrent(threads: threads) { threadIndex, indexRange in
                var indexOfNearestPoint = currentIndex + 1
                var distanceToNearestPoint = points[currentIndex].distanceSquared(to: points[indexOfNearestPoint])
                for potentialIndexOfNearestPoint in indexRange {
                    let distanceToPotentialPoint = points[currentIndex].distanceSquared(to: points[potentialIndexOfNearestPoint])
                    guard distanceToPotentialPoint < distanceToNearestPoint else { continue }
                    indexOfNearestPoint = potentialIndexOfNearestPoint
                    distanceToNearestPoint = distanceToPotentialPoint
                }
                buffer[threadIndex] = (indexOfNearestPoint, distanceToNearestPoint) // TODO: make this threadsafe
            }
            
            // Find the point with the shortest distance accross all threads
            var indexOfNearestPoint = buffer[0].0
            var distanceToNearestPoint = buffer[0].1
            for (index, distance) in buffer.dropFirst() {
                guard distance < distanceToNearestPoint else { continue }
                indexOfNearestPoint = index
                distanceToNearestPoint = distance
            }
            points.swapAt(currentIndex + 1, indexOfNearestPoint)
        }
        
        self.points = points
    }
    
    init(nearestNeighborWithOptimalStartingPosition points: [Point]) {
        guard points.count >= 2 else {
            self.init(points)
            return
        }
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
        let serialQueue = DispatchQueue(label: "Route.concurrentRandomNearestNeighborWithOptimalStartingPosition", qos: .userInitiated)
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

extension Route: MutableCollection, RandomAccessCollection {
    
    subscript(i: Int) -> Point {
        get { return points[i] }
        set { points[i] = newValue }
    }
    
    var startIndex: Int { return points.startIndex }
    
    var endIndex: Int { return points.endIndex }
}

