import Cocoa
import Dispatch

class ViewController: NSViewController {
    
    var route: Route!
    var mapView = TSPMapView(frame: CGRect(x: 0, y: 0, width: 800, height: 800))
    var textView = NSText.makeTSPInfoView(frame: NSRect(x: 690, y: 0, width: 110, height: 50))
    var exporter: RouteExporter!
    let concurrentQueue = DispatchQueue.global(qos: .userInitiated)
    
    let dataFile = "sweden"
    let flipped = true
    let updateDrawViewOnEveryXChange = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        view.addSubview(textView)
        
        concurrentQueue.async { [unowned self] in
            
            let data = readData(from: self.dataFile, flipped: self.flipped)
            self.route = Route(nearestNeighborFrom: data, startAt: 0)
            self.exporter = RouteExporter(route: self.route, max: 800)
            
            DispatchQueue.main.sync {
                self.mapView.updateDrawView(self.createPath(from: self.route))
                self.textView.setInitialTSPInfo(route: self.route)
            }
            
            var counter = 0
            let startTime = CACurrentMediaTime()
            self.route.concurrentOpt2 { opt2State in
                counter += 1
                
                //TODO: Find a way to do this on a background thread, but keep it FIFO
                if counter == self.updateDrawViewOnEveryXChange || opt2State.lastAction == .newCycle || opt2State.lastAction == .done {
                    counter = 0
                    let path = self.createPath(from: opt2State.route)
                    let time = Int(CACurrentMediaTime() - startTime)
                    DispatchQueue.main.sync { [unowned self] in
                        self.mapView.updateDrawView(path)
                        self.textView.updateTSPInfo(opt2State: opt2State, time: time)
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
