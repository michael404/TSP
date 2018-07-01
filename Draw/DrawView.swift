import Cocoa

class DrawView: NSView {
    
    private var points: [CGPoint]
    
    init(frame frameRect: NSRect, points: [CGPoint]) {
        self.points = points
        super.init(frame: frameRect)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let path = CGMutablePath()
        path.move(to: points.first!)
        path.addLines(between: points)
        path.closeSubpath()
        
        let context = NSGraphicsContext.current?.cgContext
        context?.setLineWidth(1.0)
        context?.setStrokeColor(NSColor.black.cgColor)
        context?.addPath(path)
        context?.drawPath(using: .stroke)
    }
    
    func updateDrawView(_ points: [CGPoint]) {
        self.points = points
        self.setNeedsDisplay(self.frame)
    }
    
}
