import Cocoa
import Dispatch

class ViewController: NSViewController {
    
    var route: Route!
    var drawView: DrawView!
    var textView: NSText!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: 0, y: 0, width: 800, height: 800)
        
        let data = readData(from: "sweden")
        route = Route(nearestNeighborFrom: data, startAt: 0)
        drawView = DrawView(frame: frame, points: route.export(max: 800))
        view.addSubview(drawView)
        
        textView = NSText(frame: NSRect(x: 690, y: 0, width: 110, height: 36))
        textView.isEditable = false
        textView.alignment = .right
        textView.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        textView.string = "\n\(route.distanceDescription)"
        view.addSubview(textView)
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async { [unowned self] in
            let updateCount = 50
            var counter = 0
            self.route.opt2 { opt2State in
                counter += 1
                if counter == updateCount || opt2State.lastAction == .newCycle || opt2State.lastAction == .done {
                    counter = 0
                    DispatchQueue.main.sync { [unowned self] in
                        self.drawView.updateDrawView(opt2State.route.export(max: 800))
                        self.textView.string = "\(opt2State.opt2cycle)\n" + (opt2State.lastAction == .done ? "(Done) " : "") + opt2State.route.distanceDescription
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
