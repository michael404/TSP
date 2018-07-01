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
        let path = NSBezierPath()
        path.move(to: points.first!)
        for point in points.dropFirst() {
            path.line(to: point)
        }
        path.line(to: points.first!)
        path.stroke()
    }
    
    func updateDrawView(_ points: [CGPoint]) {
        self.points = points
        self.setNeedsDisplay(self.frame)
    }
    
}
