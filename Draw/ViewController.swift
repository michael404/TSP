import Cocoa
import Dispatch

class ViewController: NSViewController {
    
    var route: Route!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: 0, y: 0, width: 800, height: 800)
        
        let data = readData(from: "sweden")
        route = Route(nearestNeighborFrom: data, startAt: 0)
        view.addSubview(DrawView(frame: frame, points: route.export(max: 800)))
        
        let textView = NSText(frame: NSRect(x: 680, y: 0, width: 120, height: 20))
        textView.isEditable = false
        textView.alignment = .right
        textView.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        textView.string = route.distanceDescription
        view.addSubview(textView)
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async { [unowned self] in
            let updateCount = 50
            var counter = 0
            self.route.opt2 { route, done in
                counter += 1
                if counter == updateCount || done {
                    counter = 0
                    DispatchQueue.main.sync {
                        let drawView = self.view.subviews[0] as! DrawView
                        let textView = self.view.subviews[1] as! NSText
                        drawView.updateDrawView(route.export(max: 800))
                        // TODO: can the new distance be calculated in the opt2 func without adding a lot of overhead?
                        var route = route
                        route.recalculateDistance()
                        switch done {
                        case false:
                            textView.string = route.distanceDescription
                        case true:
                            textView.string = "(Done) \(route.distanceDescription)"
                        }
                        
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
