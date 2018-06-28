import Cocoa

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: 0, y: 0, width: 800, height: 800)
        
        let data = readData(from: "sweden"); var route = Route(nearestNeighborFrom: data, startAt: 0)
        // var route = Route(nearestNeighborFrom: zimbabwe, startAt: 0)
        route.opt2()
        
        view.addSubview(DrawView(frame: frame, points: route.export(max: 800)))
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

