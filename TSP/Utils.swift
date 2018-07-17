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
    
    mutating func sortBasedOnMinimumDistanceToLastElement<Distance: Comparable>(startAt: Index, calculateDistance: (Element, Element) -> Distance) {
        
        swapAt(startIndex, startAt)
        var unsortedRange = self.indices
        
        while unsortedRange.count > 1 {
            let lastIndex = unsortedRange.removeFirst()
                        
            let distances = self[unsortedRange].map {
                calculateDistance(self[lastIndex], $0)
            }
            
            let (minIndexOffset, _) = distances.indexed().min { (d1, d2) in
                return d1.1 < d2.1
            }!
            
            let minIndex = self.index(lastIndex, offsetBy: minIndexOffset) + 1
            
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

extension Array {
    
    mutating func concurrentMap<BaseElement>(from base: ArraySlice<BaseElement>, transform: (BaseElement) -> Element) {
        precondition(base.count == self.count, "The base array must already contain the same number of elements as self")
        DispatchQueue.concurrentPerform(iterations: count) { index in
            self[index] = transform(base[index])
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
