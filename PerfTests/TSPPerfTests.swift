import XCTest

class TSPPerfTests: XCTestCase {

    func testPerfOpt2Short() {
        let startRoute = Route(nearestNeighborFrom: TSPData.zimbabwe , startAt: 355)
        XCTAssertEqual(startRoute.distance, 115951.15, accuracy: 0.01)
        XCTAssertEqual(startRoute.count, TSPData.zimbabwe.count)
        var route = Route(EmptyCollection())
        self.measure {
            route = startRoute
            route.opt2()
        }
        XCTAssertEqual(route.distance, 101184.92, accuracy: 0.01)
        XCTAssertEqual(route.count, TSPData.zimbabwe.count)
    }
    
    func testPerfOpt2Long() {
        let startRoute = Route(nearestNeighborFrom: TSPData.italy)
        XCTAssertEqual(startRoute.distance, 718024.79, accuracy: 0.01)
        XCTAssertEqual(startRoute.count, TSPData.italy.count)
        var route = Route(EmptyCollection())
        self.measure {
            route = startRoute
            route.opt2()
        }
        XCTAssertEqual(route.distance, 605397.34, accuracy: 0.01)
        XCTAssertEqual(route.count, TSPData.italy.count)
    }
    
    func testPerfConcurrentOpt2Short() {
        let startRoute = Route(nearestNeighborFrom: TSPData.zimbabwe, startAt: 355)
        XCTAssertEqual(startRoute.distance, 115951.16, accuracy: 0.01)
        XCTAssertEqual(startRoute.count, TSPData.zimbabwe.count)
        var route = Route(EmptyCollection())
        self.measure {
            route = startRoute
            route.concurrentOpt2()
        }
        XCTAssertEqual(route.distance, 102740.24, accuracy: 0.5)
        XCTAssertEqual(route.count, TSPData.zimbabwe.count)
    }
    
    func testPerfNNShort() {
        var route = Route(EmptyCollection())
        self.measure {
            route = Route(nearestNeighborWithOptimalStartingPositionFrom: TSPData.zimbabwe)
        }
        XCTAssertEqual(route.distance, 111827.10, accuracy: 0.01)
        XCTAssertEqual(route.count, TSPData.zimbabwe.count)
    }
    
    func testPerfNNLong() {
        var route = Route(EmptyCollection())
        self.measure {
            route = Route(nearestNeighborFrom: TSPData.sweden, startAt: 0)
        }
        XCTAssertEqual(route.distance, 1079234.56, accuracy: 0.01)
        XCTAssertEqual(route.count, TSPData.sweden.count)
    }
    
    func testPerfConcurrentNNShort() {
        var route = Route(EmptyCollection())
        self.measure {
            route = Route(nearestNeighborWithOptimalStartingPositionFrom: TSPData.zimbabwe)
        }
        XCTAssertEqual(route.distance, 111827.10, accuracy: 0.01)
        XCTAssertEqual(route.count, TSPData.zimbabwe.count)
    }
    
    func testPerfBruteforce() {
        var route = Route(EmptyCollection())
        self.measure {
            route = Route(bruteforceOptimalRouteFrom: TSPData.zimbabweSubset)
        }
        XCTAssertEqual(route.distance, 15530.744, accuracy: 0.01)
        XCTAssertEqual(route.count, TSPData.zimbabweSubset.count)
    }

}
