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
        var updated: Bool
        var opt2cycle = 1
        guard points.count >= 2 else {
            onUpdate(Opt2State(route: self, opt2cycle: opt2cycle, lastAction: .done))
            return
        }
        repeat {
            updated = false
            for i in 1...(self.endIndex-1) {
                
                // Including endIndex in the range here as a placeholder for the "wrap-around" value
                for j in (i+1)...self.endIndex {
                    
                    if distanceIsShorterForReversedRoute(between: i, and: j) {
                        self.points[i..<j].reverse()
                        updated = true
                        onUpdate(Opt2State(route: self, opt2cycle: opt2cycle, lastAction: .updated))
                    }
                }
            }
            opt2cycle += 1
            onUpdate(Opt2State(route: self, opt2cycle: opt2cycle, lastAction: .newCycle))
        } while updated
        onUpdate(Opt2State(route: self, opt2cycle: opt2cycle, lastAction: .done))
    }
    
    //TODO: Change opt2() to accept an index range
    mutating func concurrentOpt2(onUpdate: @escaping (Opt2State) -> () = { _ in }) {
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        let group = DispatchGroup()
        
        // First split it in half
        let split = self.points.splitInTwo()
        var firstHalf = Route(split.0)
        var secondHalf = Route(split.1)
        
        queue.async(group: group) { firstHalf.opt2(onUpdate: onUpdate) }
        secondHalf.opt2(onUpdate: onUpdate)
        
        group.wait()
        
        self.points = firstHalf.points
        self.points.append(contentsOf: secondHalf.points)
        opt2(onUpdate: onUpdate)
    }
    
}

struct Opt2State {
    enum LastAction { case updated, newCycle, done }
    let route: Route
    let opt2cycle: Int
    let lastAction: LastAction
}
