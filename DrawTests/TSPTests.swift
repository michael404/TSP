import XCTest

class TSPTests: XCTestCase {
    
    func testPerformanceOpt2() {
        let startRoute = Route(nearestNeighborWithOptimalStartingPosition: zimbabwe)
        XCTAssertEqual(startRoute.distance, 112019.36, accuracy: 0.5)
        var route = Route(EmptyCollection())
        self.measure {
            route = startRoute
            route.opt2()
        }
        XCTAssertEqual(route.distance, 102094.84, accuracy: 0.5)
    }
    
    func testPerformanceConcurrentOpt2() {
        let startRoute = Route(nearestNeighborWithOptimalStartingPosition: zimbabwe)
        XCTAssertEqual(startRoute.distance, 112019.36, accuracy: 0.5)
        var route = Route(EmptyCollection())
        self.measure {
            route = startRoute
            route.concurrentOpt2()
        }
        XCTAssertEqual(route.distance, 101045.19, accuracy: 0.5)
    }
    
    func testPerformanceNN() {
        var route = Route(EmptyCollection())
        self.measure {
            route = Route(nearestNeighborWithOptimalStartingPosition: zimbabwe)
        }
        XCTAssertEqual(route.distance, 112019.36, accuracy: 0.5)
    }
    
    func testPerformanceNNConcurrent() {
        var route = Route(EmptyCollection())
        self.measure {
            route = Route(concurrentRandomNearestNeighborWithOptimalStartingPosition: zimbabwe)
        }
        XCTAssertEqual(route.distance, 112019.36, accuracy: 0.5)
    }
    
    func testPerformanceBruteforce() {
        var route = Route(EmptyCollection())
        self.measure {
            route = Route(bruteforceOptimalRouteFrom: zimbabweSubset)
        }
        XCTAssertEqual(route.distance, 15530.744, accuracy: 0.01)
        XCTAssertEqual(route.count, 10)
    }
    
    func testConcurrentAndNonConcurrentRouteInit() {
        let route1 = Route(nearestNeighborWithOptimalStartingPosition: zimbabwe)
        let route2 = Route(concurrentRandomNearestNeighborWithOptimalStartingPosition: zimbabwe)
        XCTAssertEqual(route1, route2)
    }
    
    func testPointDescription() {
        let point = Point.init(1.25, 4)
        XCTAssertEqual(point.description, "(1.25, 4.0)")
    }
    
    func testLineDistance() {
        let a = Point(1.5, 5)
        let b = Point(10, .pi)
        let line = Line(a, b)
        XCTAssertEqual(line.distance, 8.700786049, accuracy: 0.01)
    }
    
    func testRouteCollection() {
        let route = Route([Point(1,2), Point(3,4), Point(5,6), Point(3,3)])
        XCTAssertEqual(route.count, 4)
        XCTAssertEqual(route[0], Point(1,2))
        XCTAssertEqual(route[2], Point(5,6))
    }
    
    func testRouteDistance() {
        let route = Route([Point(1,2), Point(3,4), Point(5,6), Point(3,3)])
        let expected = 11.4985 as Float
        XCTAssertEqual(route.distance, expected, accuracy: 0.1)
    }
    
    func testRouteNearestNeighborAndOpt2() {
        var route = Route.init(nearestNeighborFrom: [Point(1,2), Point(2.5,4), Point(5,6), Point(3,3)], startAt: 0)
        XCTAssertTrue(route.elementsEqual([Point(1,2), Point(3,3), Point(2.5,4), Point(5,6)]))
        XCTAssertEqual(route.distance, 12.21251833, accuracy: 0.01)
        
        route.opt2()
        XCTAssertTrue(route.elementsEqual([Point(1,2), Point(3,3), Point(5,6), Point(2.5,4)]))
        XCTAssertEqual(route.distance, 11.54318137, accuracy: 0.01)
    }
    
    func testRouteBruteforce() {
        var route = Route(bruteforceOptimalRouteFrom: [Point(1,2), Point(2.5,4), Point(5,6), Point(3,3)])
        let expectedDistance: Float = 11.543181
        XCTAssertEqual(route.distance, expectedDistance, accuracy: 0.01)
        // The exact order can be arbitrary, but opt2 should not change anything
        route.opt2()
        XCTAssertEqual(route.distance, expectedDistance, accuracy: 0.01)
    }
    
    func testReadData() {
        do {
            let dataset = readData(from: "sweden", flipped: false)
            XCTAssertEqual(dataset.count, 24978)
            XCTAssertEqual(dataset.first, Point(55333.3333, 13316.6667))
        }
        do {
            let dataset = readData(from: "sweden", flipped: true)
            XCTAssertEqual(dataset.count, 24978)
            XCTAssertEqual(dataset.first, Point(13316.6667, 55333.3333))
        }
    }
    
    func testSortBasedOnMinimumDistanceToLastElement() {
        do {
            var array = [4,2,3,7,3,7,8,9]
            array.sortBasedOnMinimumDistanceToLastElement(startAt: 7) { return abs($1 - $0) }
            XCTAssertEqual(array, [9,8,7,7,4,3,3,2])
        }
        do {
            var array = [4,2,3,7,3,7,8,9]
            array.sortBasedOnMinimumDistanceToLastElement(startAt: 3) { return abs($1 - $0) }
            XCTAssertEqual(array, [7,7,8,9,4,3,3,2])
            
        }
    }
    
    func testRouteExporter() {
        let points = [Point(10.5,20), Point(100,200), Point(40, 80)]
        let route = Route(points)
        let exporter = RouteExporter(route: route, max: 100)
        
        XCTAssertEqual(exporter.minX, 10.5, accuracy: 0.01)
        XCTAssertEqual(exporter.minY, 20, accuracy: 0.01)
        XCTAssertEqual(exporter.scale, 0.555555556, accuracy: 0.01)
        
        let exported = exporter.export(route)
        
        XCTAssertEqual(exported[0], CGPoint(x: 0, y: 0))
        XCTAssertEqual(exported[1], CGPoint(x: 50, y: 100))
        XCTAssertEqual(exported[2], CGPoint(x: 16, y: 33))
        
    }
    
    func testRouteWithNoOrFewPoints() {
        do {
            let points: [Point] = []
            
            var route = Route(points)
            XCTAssertEqual(route.distance, 0.0)
            XCTAssertEqual(route.count, 0)
            
            route.opt2()
            XCTAssertEqual(route.distance, 0.0)
            XCTAssertEqual(route.count, 0)
            
            route = Route(bruteforceOptimalRouteFrom: points)
            XCTAssertEqual(route.distance, 0.0)
            XCTAssertEqual(route.count, 0)
            
            route = Route(nearestNeighborFrom: points, startAt: 0)
            XCTAssertEqual(route.distance, 0.0)
            XCTAssertEqual(route.count, 0)
            
            route = Route(nearestNeighborWithOptimalStartingPosition: points)
            XCTAssertEqual(route.distance, 0.0)
            XCTAssertEqual(route.count, 0)
            
            route = Route(concurrentRandomNearestNeighborWithOptimalStartingPosition: points)
            XCTAssertEqual(route.distance, 0.0)
            XCTAssertEqual(route.count, 0)
        }
        do {
            let points: [Point] = [Point(1,2)]
            
            var route = Route(points)
            XCTAssertEqual(route.distance, 0.0)
            XCTAssertEqual(route.count, 1)
            
            route.opt2()
            XCTAssertEqual(route.distance, 0.0)
            XCTAssertEqual(route.count, 1)
            
            route = Route(bruteforceOptimalRouteFrom: points)
            XCTAssertEqual(route.distance, 0.0)
            XCTAssertEqual(route.count, 1)
            
            route = Route(nearestNeighborFrom: points, startAt: 0)
            XCTAssertEqual(route.distance, 0.0)
            XCTAssertEqual(route.count, 1)
            
            route = Route(nearestNeighborWithOptimalStartingPosition: points)
            XCTAssertEqual(route.distance, 0.0)
            XCTAssertEqual(route.count, 1)
            
            route = Route(concurrentRandomNearestNeighborWithOptimalStartingPosition: points)
            XCTAssertEqual(route.distance, 0.0)
            XCTAssertEqual(route.count, 1)
        }
        do {
            let points: [Point] = [Point(1,2), Point(4,5), Point(4,2)]
            
            var route = Route(points)
            XCTAssertEqual(route.distance, 10.2426, accuracy: 0.01)
            XCTAssertEqual(route.count, 3)
            
            route.opt2()
            XCTAssertEqual(route.distance, 10.2426, accuracy: 0.01)
            XCTAssertEqual(route.count, 3)

            route = Route(bruteforceOptimalRouteFrom: points)
            XCTAssertEqual(route.distance, 10.2426, accuracy: 0.01)
            XCTAssertEqual(route.count, 3)

            route = Route(nearestNeighborFrom: points, startAt: 0)
            XCTAssertEqual(route.distance, 10.2426, accuracy: 0.01)
            XCTAssertEqual(route.count, 3)

            route = Route(nearestNeighborWithOptimalStartingPosition: points)
            XCTAssertEqual(route.distance, 10.2426, accuracy: 0.01)
            XCTAssertEqual(route.count, 3)

            route = Route(concurrentRandomNearestNeighborWithOptimalStartingPosition: points)
            XCTAssertEqual(route.distance, 10.2426, accuracy: 0.01)
            XCTAssertEqual(route.count, 3)
        }
    }
    
    func testSplitInTwo() {
        do {
            let split = (0..<10).splitInTwo()
            XCTAssertEqual(split.0, (0..<5))
            XCTAssertEqual(split.1, (5..<10))
        }
        // Uneven number of items
        do {
            let split = (0..<11).splitInTwo()
            XCTAssertEqual(split.0, (0..<6))
            XCTAssertEqual(split.1, (6..<11))
        }
        // Array
        do {
            let split = Array(0..<11).splitInTwo()
            XCTAssertEqual(split.0, [0,1,2,3,4,5])
            XCTAssertEqual(split.1, [6,7,8,9,10])
        }
        
    }
}
