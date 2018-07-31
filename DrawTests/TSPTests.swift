import XCTest

class TSPTests: XCTestCase {
    
    func testPerformanceOpt2() {
        let startRoute = Route(nearestNeighborFrom: TSPData.zimbabwe , startAt: 355)
        XCTAssertEqual(startRoute.distance, 112019.36, accuracy: 0.5)
        XCTAssertEqual(startRoute.count, TSPData.zimbabwe.count)
        var route = Route(EmptyCollection())
        self.measure {
            route = startRoute
            route.opt2()
        }
        XCTAssertEqual(route.distance, 102094.84, accuracy: 0.5)
        XCTAssertEqual(route.count, TSPData.zimbabwe.count)
    }
    
    func testPerformanceOpt2LongRoute() {
        let startRoute = Route(nearestNeighborFrom: TSPData.italy , startAt: 0)
        XCTAssertEqual(startRoute.distance, 710974.75, accuracy: 0.5)
        XCTAssertEqual(startRoute.count, TSPData.italy.count)
        var route = Route(EmptyCollection())
        self.measure {
            route = startRoute
            route.opt2()
        }
        XCTAssertEqual(route.distance, 608482.7, accuracy: 0.5)
        XCTAssertEqual(route.count, TSPData.italy.count)
    }
    
    func testPerformanceConcurrentOpt2() {
        let startRoute = Route(nearestNeighborFrom: TSPData.zimbabwe, startAt: 355)
        XCTAssertEqual(startRoute.distance, 112019.36, accuracy: 0.5)
        XCTAssertEqual(startRoute.count, TSPData.zimbabwe.count)
        var route = Route(EmptyCollection())
        self.measure {
            route = startRoute
            route.concurrentOpt2()
        }
        XCTAssertEqual(route.distance, 101045.19, accuracy: 0.5)
        XCTAssertEqual(route.count, TSPData.zimbabwe.count)
    }
    
    func testPerformanceNN() {
        var route = Route(EmptyCollection())
        self.measure {
            route = Route(nearestNeighborWithOptimalStartingPosition: TSPData.zimbabwe)
        }
        XCTAssertEqual(route.distance, 112019.36, accuracy: 0.5)
        XCTAssertEqual(route.count, TSPData.zimbabwe.count)
    }
    
    func testPerformanceNNLongRoute() {
        var route = Route(EmptyCollection())
        self.measure {
            route = Route(nearestNeighborFrom: TSPData.sweden, startAt: 0)
        }
        XCTAssertEqual(route.distance, 1078975.9, accuracy: 0.5)
        XCTAssertEqual(route.count, TSPData.sweden.count)
    }
    
    func testPerformanceNNConcurrent() {
        var route = Route(EmptyCollection())
        self.measure {
            route = Route(concurrentRandomNearestNeighborWithOptimalStartingPosition: TSPData.zimbabwe)
        }
        XCTAssertEqual(route.distance, 112019.36, accuracy: 0.5)
        XCTAssertEqual(route.count, TSPData.zimbabwe.count)
    }
    
    func testPerformanceBruteforce() {
        var route = Route(EmptyCollection())
        self.measure {
            route = Route(bruteforceOptimalRouteFrom: TSPData.zimbabweSubset)
        }
        XCTAssertEqual(route.distance, 15530.744, accuracy: 0.01)
        XCTAssertEqual(route.count, TSPData.zimbabweSubset.count)
    }
    
    func testConcurrentAndNonConcurrentRouteInit() {
        let route1 = Route(nearestNeighborWithOptimalStartingPosition: TSPData.zimbabwe)
        let route2 = Route(concurrentRandomNearestNeighborWithOptimalStartingPosition: TSPData.zimbabwe)
        XCTAssertEqual(route1, route2)
    }
    
    func testPointDescription() {
        let point = Point.init(1.25, 4)
        XCTAssertEqual(point.description, "(1.25, 4.0)")
    }
    
    func testDistance() {
        let a = Point(1.5, 5)
        let b = Point(10, .pi)
        XCTAssertEqual(a.distance(to: b), 8.700786049, accuracy: 0.01)
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
            let dataset = TSPData.readData(from: "sweden", flipped: false)
            XCTAssertEqual(dataset.count, 24978)
            XCTAssertEqual(dataset.first, Point(55333.3333, 13316.6667))
        }
        do {
            let dataset = TSPData.readData(from: "sweden", flipped: true)
            XCTAssertEqual(dataset.count, 24978)
            XCTAssertEqual(dataset.first, Point(13316.6667, 55333.3333))
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
    
    func testPerformConcurrent() {
        for _ in 0..<20 {
            let rangeCount = Int.random(in: 10..<100)
            let threadCount = Int.random(in: 5..<rangeCount)
            var rangeCheck = Array<Bool>(repeating: false, count: rangeCount)
            var threadCheck = Array<Bool>(repeating: false, count: threadCount)
            let q = DispatchQueue(label: "test")
            (0..<rangeCount).performConcurrent(threads: threadCount) { thread, range in
                q.sync {
                    XCTAssertFalse(threadCheck[thread], "Expected index \(thread) of threadCheck to be false")
                    threadCheck[thread] = true
                    for i in range {
                        XCTAssertFalse(rangeCheck[i], "Expected index \(i) of rangeCheck to be false")
                        rangeCheck[i] = true
                    }
                }
            }
            XCTAssertEqual(rangeCheck, Array<Bool>(repeating: true, count: rangeCount), "Did not set one of the indicies when using rangeCount \(rangeCount) and threadcount \(threadCount). First non-set index: \(rangeCheck.firstIndex(of: false)!)")
            
            XCTAssertEqual(threadCheck, Array<Bool>(repeating: true, count: threadCount))
        }
    }
    
}
