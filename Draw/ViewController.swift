import Cocoa
import Dispatch

class ViewController: NSViewController {
    
    var route: Route!
    var drawView = DrawView(frame: CGRect(x: 0, y: 0, width: 800, height: 800))
    var textView = NSText(frame: NSRect(x: 690, y: 0, width: 110, height: 50))
    var exporter: RouteExporter!
    let backgroundQueue = DispatchQueue.global(qos: .userInitiated)
    
    let dataFile = "italy"
    let flipped = true
    let updateDrawViewOnEveryXChange = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(drawView)
        
        textView.isEditable = false
        textView.alignment = .right
        textView.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        textView.string = "Loading..."
        view.addSubview(textView)
        
        backgroundQueue.async { [unowned self] in
            
            let data = readData(from: self.dataFile, flipped: self.flipped)
            self.route = Route(nearestNeighborFrom: data, startAt: 0)
            self.exporter = RouteExporter(route: self.route, max: 800)
            
            DispatchQueue.main.sync {
                self.drawView.updateDrawView(self.createPath(from: self.route))
                self.textView.string = "\n\(self.route.distanceDescription)"
            }
            
            var counter = 0
            let startTime = CACurrentMediaTime()
            self.route.concurrentOpt2 { opt2State in
                counter += 1
                if counter == self.updateDrawViewOnEveryXChange || opt2State.lastAction == .newCycle || opt2State.lastAction == .done {
                    counter = 0
                    let path = self.createPath(from: opt2State.route)
                    let doneText = opt2State.lastAction == .done ? "(Done) " : ""
                    let time = Int(CACurrentMediaTime() - startTime)
                    let text = """
                            Time: \(time)
                            Opt2 cycle: \(opt2State.opt2cycle)
                            \(doneText) \(opt2State.route.distanceDescription)
                            """
                    DispatchQueue.main.sync { [unowned self] in
                        self.drawView.updateDrawView(path)
                        self.textView.string = text
                    }
                }
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func createPath(from route: Route) -> CGPath {
        let points = exporter.export(route)
        let path = CGMutablePath()
        path.addLines(between: points)
        path.closeSubpath()
        return path
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
