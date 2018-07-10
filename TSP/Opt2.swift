import Foundation

extension Route {
    
    private func distanceIsShorterForReversedRoute(between i: Int, and j: Int) -> Bool {
        
        let a = self[i-1]
        let b = self[i]
        let c = self[j-1]
        let d = j == endIndex ? self[startIndex] : self[j]
        
        return Line(a, c).distance + Line(b, d).distance < Line(a, b).distance + Line(c, d).distance
    }
    
    mutating func opt2(onUpdate: (Opt2State) -> () = { _ in }) {
        
        var opt2cycle = 1
        
        guard points.count >= 2 else {
            onUpdate(Opt2State(route: self, opt2cycle: opt2cycle, lastAction: .done))
            return
        }
        
        var updatedRange: Range<Int>? = 0..<endIndex
        repeat {
            guard let lastUpdatedRange = updatedRange else { break }
            updatedRange = nil
            for i in 1..<lastUpdatedRange.upperBound {
                let jStart = i < lastUpdatedRange.lowerBound ? lastUpdatedRange.lowerBound : (i + 1)
                // Including endIndex in the range here as a placeholder for the "wrap-around" value
                for j in jStart...lastUpdatedRange.upperBound {
                    if distanceIsShorterForReversedRoute(between: i, and: j) {
                        self.points[i..<j].reverse()
                        if let _updated = updatedRange {
                            //TODO: Find out if this can ever be 0, which would trap on self[i - 1]
                            let newStart = Swift.min(_updated.lowerBound, i - 1)
                            let newEnd = Swift.max(_updated.upperBound, j)
                            updatedRange = newStart..<newEnd
                        } else {
                            updatedRange = i..<j
                        }
                        onUpdate(Opt2State(route: self, opt2cycle: opt2cycle, lastAction: .updated))
                    }
                }
            }
            opt2cycle += 1
            onUpdate(Opt2State(route: self, opt2cycle: opt2cycle, lastAction: .newCycle))
        } while true
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
