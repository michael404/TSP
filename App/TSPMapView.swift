import Cocoa

class TSPMapView: NSView {
    
    private var path: CGPath
    private var done: Bool = false
    
    init(frame: NSRect, path: CGPath) {
        self.path = path
        super.init(frame: frame)
    }
    
    /// Initializes an empty DrawView
    override init(frame frameRect: NSRect) {
        self.path = CGMutablePath()
        super.init(frame: frameRect)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1).setFill()
        dirtyRect.fill()
        let context = NSGraphicsContext.current!.cgContext
        context.setLineWidth(1.0)
        switch self.done {
        case false: context.setStrokeColor(NSColor.black.cgColor)
        case true: context.setStrokeColor(NSColor(red: 0, green: 0.4, blue: 0, alpha: 1).cgColor)
        }
        context.addPath(path)
        context.drawPath(using: .stroke)
    }
    
    func updateMapView(path: CGPath, done: Bool = false) {
        self.path = path
        self.done = done
        self.setNeedsDisplay(self.frame)
    }
    
}
