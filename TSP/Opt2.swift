extension Route {
    
    private func distanceIsShorterForReversedRoute(between i: Int, and j: Int) -> Bool {
        
        let a = self[i-1]
        let b = self[i]
        let c = self[j-1]
        let d = j == endIndex ? self[startIndex] : self[j]
        
        return Line(a, c).distance + Line(b, d).distance < Line(a, b).distance + Line(c, d).distance
    
    }
    
    mutating func opt2() {
        var updated: Bool
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
                    }
                }
            }
        } while updated
        // Recalculate correct self.distance
        recalculateDistance()
    }
    
}
