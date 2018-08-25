import Foundation

enum TSPData {
    
    static let zimbabwe = _zimbabwe
    static let zimbabweSubset = _zimbabweSubset
    static let sweden = TSPData.readData(from: "sweden", flipped: true)
    static let italy = TSPData.readData(from: "italy", flipped: true)
    static let monaLisa = TSPData.readData(from: "mona-lisa", flipped: false)
    
}

extension TSPData {
    
    static func readData(from file: String, flipped: Bool = false) -> [Point] {
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("TSP.app")
            .appendingPathComponent("Contents")
            .appendingPathComponent("Resources")
            .appendingPathComponent("\(file).txt")
        do {
            let data = try Data.init(contentsOf: url)
            guard let text = String.init(data: data, encoding: .utf8) else {
                fatalError("Could not parse file contents as utf8.")
            }
            return parseData(text, flipped: flipped)
        } catch {
            fatalError("Could not open file \"\(url)\". Error: \(error)")
        }
    }
    
    private static func parseData(_ text: String, flipped: Bool) -> [Point] {
        let lines = text.split(separator: "\n")
        let values = lines.map { $0.split(separator: ",") }
        let result = values.reduce(into: [Point]()) { result, next in
            let point = flipped ? Point(Float(next[2])!, Float(next[1])!) : Point(Float(next[1])!, Float(next[2])!)
            result.append(point)
        }
        return result
    }
    
}
