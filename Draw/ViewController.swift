import Cocoa
import Dispatch

class ViewController: NSViewController {
    
    var route: Route!
    var drawView: DrawView!
    var textView: NSText!
    var exporter: RouteExporter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: 0, y: 0, width: 800, height: 800)
        
        drawView = DrawView(frame: frame)
        view.addSubview(drawView)
        
        textView = NSText(frame: NSRect(x: 690, y: 0, width: 110, height: 36))
        textView.isEditable = false
        textView.alignment = .right
        textView.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        textView.string = "Loading..."
        view.addSubview(textView)
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        queue.async { [unowned self] in
            
            let data = readData(from: "sweden")
            self.route = Route(nearestNeighborFrom: data, startAt: 0)
            self.exporter = RouteExporter(route: self.route, max: 800)
            
            DispatchQueue.main.sync {
                self.drawView.updateDrawView(self.createPath(from: self.route))
                self.textView.string = "\n\(self.route.distanceDescription)"
            }
            
            let updateCount = 50
            var counter = 0
            self.route.opt2 { opt2State in
                counter += 1
                if counter == updateCount || opt2State.lastAction == .newCycle || opt2State.lastAction == .done {
                    counter = 0
                    let path = self.createPath(from: opt2State.route)
                    let text = "\(opt2State.opt2cycle)\n" + (opt2State.lastAction == .done ? "(Done) " : "") + opt2State.route.distanceDescription
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
