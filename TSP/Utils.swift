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

extension Array {
    
    //TODO: Move this to route - makes no sense to make this generic over Array or Collection
    mutating func sortBasedOnMinimumDistanceToLastElement(startAt: Index, calculateDistance: (Element, Element) -> Float) {
        
        swapAt(startIndex, startAt)
        var unsortedRange = self.indices
        
        var distanceBuffer = Array<Float>(repeating: 0.0, count: self.count)
        
        while unsortedRange.count > 1 {
            let lastIndex = unsortedRange.removeFirst()
            
            print("start perfomconcurrent")
            
            unsortedRange.performConcurrent(threads: 4) { range in
                for i in range {
                    distanceBuffer[i] = calculateDistance(self[lastIndex], self[i])
                }
            }
            
            print("start findin min")
            
            var minIndex = -1
            var minDistance = Float.infinity
            var index = unsortedRange.lowerBound
            
            repeat {
                if distanceBuffer[index] < minDistance {
                    minIndex = index
                    minDistance = distanceBuffer[index]
                }
                formIndex(after: &index)
            } while index != unsortedRange.upperBound
            
            print("done")
            
            swapAt(unsortedRange.lowerBound, minIndex)
        }
    }
    
}

extension RandomAccessCollection {
    
    func splitInTwo() -> (SubSequence, SubSequence) {
        let splitIndex = index(endIndex, offsetBy: -count / 2)
        return (self[startIndex..<splitIndex], self[splitIndex..<endIndex])
    }
    
}

extension RandomAccessCollection {
    
    func performConcurrent(threads: Int, operation: (SubSequence) -> ()) {
        let chunkSize = Double(self.count) / Double(threads)
        DispatchQueue.concurrentPerform(iterations: threads) { thread in
            let _startOffset = chunkSize * Double(thread)
            let _endOffset = _startOffset + chunkSize
            let startOffset = Int(_startOffset.rounded())
            let endOffset = Int(_endOffset.rounded())
            let chunk = self[index(startIndex, offsetBy: startOffset)..<index(startIndex, offsetBy: endOffset)]
            operation(chunk)
        }
        
    }
    
}

extension Collection {
    
    func indexed() -> IndexedCollection<Self> {
        return IndexedCollection(self)
    }
    
}

struct IndexedCollection<Base: Collection>: Collection {

    typealias Element = (Base.Index, Base.Element)
    typealias Index = Base.Index
    
    let base: Base
    
    fileprivate init(_ base: Base) {
        self.base = base
    }
    
    var startIndex: Base.Index { return base.startIndex }
    var endIndex: Base.Index { return base.endIndex }
    func index(after i: Base.Index) -> Base.Index { return base.index(after: i) }
    
    subscript(i: Base.Index) -> (Base.Index, Base.Element) {
        @inline(__always)
        get {
            return (i, base[i])
        }
    }
    
}

extension IndexedCollection: BidirectionalCollection where Base: BidirectionalCollection {
    func index(before i: Base.Index) -> Base.Index { return base.index(before: i) }
}

extension IndexedCollection: RandomAccessCollection where Base: RandomAccessCollection { }
