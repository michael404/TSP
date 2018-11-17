import Cocoa

extension NSText {
    
    static func makeTSPInfoView(frame: NSRect) -> NSText {
        let result = NSText(frame: frame)
        result.isEditable = false
        result.alignment = .right
        result.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        result.string = "Loading..."
        return result
    }
    
    func setInitialTSPInfo(route: Route) {
        string = "\n\n\(route.distanceDescription)"
    }
    
    func updateTSPInfo(opt2State: Opt2State, time: Int) {
        let doneText = opt2State.lastAction == .done ? "(Done) " : ""
        self.string = """
            Time: \(time)
            Opt2 cycle: \(opt2State.opt2cycle)
            \(doneText) \(opt2State.route.distanceDescription)
            """
    }
    
}

fileprivate extension Route {
    
    var distanceDescription: String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.hasThousandSeparators = true
        nf.thousandSeparator = " "
        nf.maximumFractionDigits = 0
        let distance = NSNumber(value: self.distance)
        return nf.string(from: distance)!
    }
    
}
