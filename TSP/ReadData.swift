import Foundation

func readData(from file: String, flipped: Bool = false) -> [Point] {
    guard let filePath = Bundle.main.url(forResource: file, withExtension: "txt") else {
        fatalError("Could not find file '\(file).txt in bundle'")
    }
    do {
        let data = try Data.init(contentsOf: filePath)
        guard let text = String.init(data: data, encoding: .utf8) else {
            fatalError("Could not parse file contents as utf8.")
        }
        return parseData(text, flipped: flipped)
    } catch {
        fatalError("Could not parse contents of file. \(error.localizedDescription)")
    }
}

fileprivate func parseData(_ text: String, flipped: Bool) -> [Point] {
    let lines = text.split(separator: "\n")
    let values = lines.map { $0.split(separator: ",") }
    let result = values.reduce(into: [Point]()) { result, next in
        let point = flipped ? Point(Float(next[2])!, Float(next[1])!) : Point(Float(next[1])!, Float(next[2])!)
        result.append(point)
    }
    return result
}
