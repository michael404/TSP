import Foundation

extension Collection where Element: Hashable {
    
    /// Checks if all elements in the sequence are unique
    ///
    /// - Returns: `true` if all elements are unique, otherwise `false`
    var elementsAreUnique: Bool {
        var set = Set<Element>(minimumCapacity: self.count)
        for element in self {
            guard set.insert(element).inserted else { return false }
        }
        return true
    }
    
}

extension Float {
    
    private static let roundedFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.localizesFormat = false
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 0
        nf.thousandSeparator = " "
        return nf
    }()
    
    var roundedString: String {
        return Float.roundedFormatter.string(from: NSNumber(value: self))!
    }
}

extension RandomAccessCollection where Self: MutableCollection {
    
    mutating func sortBasedOnMinimumDistanceToLastElement<Distance: Comparable>(startAt: Index, calculateDistance: (Element, Element) -> Distance) {
        swapAt(startIndex, startAt)
        for currentIndex in indices.dropLast() {
            var indexOfNearestPoint = index(after: currentIndex)
            var distanceToNearestPoint = calculateDistance(self[currentIndex], self[indexOfNearestPoint])
            let indiciesToSearchThrough = self[index(after: indexOfNearestPoint)..<self.endIndex].indices
            for potentialIndexOfNearestPoint in indiciesToSearchThrough {
                let distanceToPotentialPoint = calculateDistance(self[currentIndex], self[potentialIndexOfNearestPoint])
                guard distanceToPotentialPoint < distanceToNearestPoint else { continue }
                indexOfNearestPoint = potentialIndexOfNearestPoint
                distanceToNearestPoint = distanceToPotentialPoint
            }
            swapAt(index(after: currentIndex), indexOfNearestPoint)
        }
    }
    
}

extension RandomAccessCollection {
    
    func splitInTwo() -> (SubSequence, SubSequence) {
        let splitIndex = index(endIndex, offsetBy: -count / 2)
        return (self[startIndex..<splitIndex], self[splitIndex..<endIndex])
    }
    
}
