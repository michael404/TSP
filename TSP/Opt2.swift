import Foundation

extension Route {
    
    @inline(__always)
    private func distanceIsShorterForReversedRoute(between i: Int, and j: Int) -> Bool {
        
        let a = self[i-1]
        let b = self[i]
        let c = self[j-1]
        let d = self[j == endIndex ? startIndex : j]
        
        // The implementation below is a small performance boost compared to the simple verion:
        // return a.distance(to: c) + b.distance(to: d) < a.distance(to: b) + c.distance(to: d)

        let abSq = a.distanceSquared(to: b)
        let cdSq = c.distanceSquared(to: d)
        let acSq = a.distanceSquared(to: c)
        let bdSq = b.distanceSquared(to: d)
        
        // Fast path where we can garantee that the current path is better without
        // calculating the square root
        if (abSq < acSq && cdSq < bdSq) || (abSq < bdSq && cdSq < acSq) { return false }
        
        // Normal path
        return acSq.squareRoot() + bdSq.squareRoot() < abSq.squareRoot() + cdSq.squareRoot()
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
