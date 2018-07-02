import Cocoa

class DrawView: NSView {
    
    private var path: CGPath
    
    init(frame frameRect: NSRect, path: CGPath) {
        self.path = path
        super.init(frame: frameRect)
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
