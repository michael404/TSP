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
        let dataset = readData(from: "sweden")
        XCTAssertEqual(dataset.count, 24978)
        XCTAssertEqual(dataset.first, Point(13316.6667, 55333.3333))
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
    
}
