import Cocoa

class TSPMapView: NSView {
    
    private var path: CGPath
    
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
        NSColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).setFill()
        dirtyRect.fill()
        let context = NSGraphicsContext.current?.cgContext
        context?.setLineWidth(1.0)
        context?.setStrokeColor(NSColor.black.cgColor)
        context?.addPath(path)
        context?.drawPath(using: .stroke)
    }
    
    func updateDrawView(_ path: CGPath) {
        self.path = path
        self.setNeedsDisplay(self.frame)
    }
    
}
