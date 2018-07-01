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
        repeat {
            updated = false
            for i in 1...(self.endIndex-1) {
                
                // Including endIndex in the range here as a placeholder for the "wrap-around" value
                for j in (i+1)...self.endIndex {
                                                            
                    if distanceIsShorterForReversedRoute(between: i, and: j) {
                        self.points[i..<j].reverse()
                        updated = true
                        // We do not update self.distance here, which means it will be incorrect
                        // This is ok as we do not use it
                        // TODO: This means the closure here gets passed a Route with an incorrect distance!
                        onUpdate(Opt2State(route: self, opt2cycle: opt2cycle, lastAction: .updated))
                    }
                }
            }
            opt2cycle += 1
            onUpdate(Opt2State(route: self, opt2cycle: opt2cycle, lastAction: .newCycle))
        } while updated
        onUpdate(Opt2State(route: self, opt2cycle: opt2cycle, lastAction: .done))
    }
    
}

struct Opt2State {
    enum LastAction { case updated, newCycle, done }
    let route: Route
    let opt2cycle: Int
    let lastAction: LastAction
}
