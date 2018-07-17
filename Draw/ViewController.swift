import Cocoa
import Dispatch

class ViewController: NSViewController {
    
    var route: Route!
    var mapView = TSPMapView(frame: CGRect(x: 0, y: 0, width: 800, height: 800))
    var textView = NSText.makeTSPInfoView(frame: NSRect(x: 690, y: 0, width: 110, height: 50))
    var exporter: RouteExporter!
    let concurrentQueue = DispatchQueue.global(qos: .userInitiated)
    
    let data = TSPData.sweden
    let timeBetweenUIUpdates = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        view.addSubview(textView)
        
        concurrentQueue.async { [unowned self] in
            
            self.route = Route(nearestNeighborFrom: self.data, startAt: 0)
            self.exporter = RouteExporter(route: self.route, max: 800)
            
            DispatchQueue.main.sync {
                self.mapView.updateDrawView(self.createPath(from: self.route))
                self.textView.setInitialTSPInfo(route: self.route)
            }
            
            let startTime = CACurrentMediaTime()
            var lastUpdatedTime = startTime
            self.route.concurrentOpt2 { opt2State in
                if self.shoudUpdateUI(&lastUpdatedTime, opt2State) {
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
    
    func shoudUpdateUI(_ lastUpdatedTime: inout Double, _ opt2State: Opt2State) -> Bool {
        let currentTime = CACurrentMediaTime()
        if (lastUpdatedTime + self.timeBetweenUIUpdates) < currentTime
        || opt2State.lastAction == .newCycle
        || opt2State.lastAction == .done {
            lastUpdatedTime = currentTime
            return true
        }
        return false
    }

}
