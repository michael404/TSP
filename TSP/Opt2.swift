import Foundation

extension Route {
    
    private func distanceIsShorterForReversedRoute(between i: Int, and j: Int) -> Bool {
        
//        if j == endIndex { print("############## J = ENDINDEX. I = \(i) j = \(j). Count \(count)") }
        
        let a = self[i-1]
        let b = self[i]
        let c = self[j-1]
        let d = j == endIndex ? self[startIndex] : self[j]
        
        return Line(a, c).distance + Line(b, d).distance < Line(a, b).distance + Line(c, d).distance
    }
    
    mutating func opt2(onUpdate: (Opt2State) -> () = { _ in }) {
        guard count > 2 else { return }
        var updated: (Int, Int)? = (1, endIndex)
        var opt2cycle = 1
        guard points.count >= 2 else {
            onUpdate(Opt2State(route: self, opt2cycle: opt2cycle, lastAction: .done))
            return
        }
        repeat {
            let lastUpdated = updated! // Set to non-nil in start and loop breaks if it is non-nill
            //TODO: Use optionals
            updated = nil
            for i in lastUpdated.0..<lastUpdated.1 {
                // Including endIndex in the range here as a placeholder for the "wrap-around" value
                for j in (i + 1)...lastUpdated.1 {
//                    print("i: \(i) j: \(j)")
                    if distanceIsShorterForReversedRoute(between: i, and: j) {
                        self.points[i..<j].reverse()
                        
                        if let _updated = updated {
                            let newStart = Swift.min(_updated.0, i)
                            let newEnd = Swift.max(_updated.1, j)
                            updated = (newStart, newEnd)
                        } else {
                            updated = (i, j)
                        }
                        onUpdate(Opt2State(route: self, opt2cycle: opt2cycle, lastAction: .updated))
                    }
                }
                
            }
            opt2cycle += 1
            onUpdate(Opt2State(route: self, opt2cycle: opt2cycle, lastAction: .newCycle))
//            print("\(updated)")
        } while updated != nil
        onUpdate(Opt2State(route: self, opt2cycle: opt2cycle, lastAction: .done))
    }
    
    //TODO: Change opt2() to accept an index range
    mutating func concurrentOpt2(onUpdate: @escaping (Opt2State) -> () = { _ in }) {
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        let group = DispatchGroup()
        
        // First split it in half
        let split = self.splitInTwo()
        var firstHalf = Route(split.0)
        var secondHalf = Route(split.1)
        
        queue.async(group: group) { firstHalf.opt2(onUpdate: onUpdate) }
        queue.async(group: group) { secondHalf.opt2(onUpdate: onUpdate) }
        group.wait()
        
        self = firstHalf
        self.points.append(contentsOf: secondHalf)
        opt2(onUpdate: onUpdate)
    }
    
}

struct Opt2State {
    enum LastAction { case updated, newCycle, done }
    let route: Route
    let opt2cycle: Int
    let lastAction: LastAction
}
