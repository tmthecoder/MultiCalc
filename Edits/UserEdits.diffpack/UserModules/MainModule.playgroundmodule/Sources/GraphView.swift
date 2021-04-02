
import UIKit
import CoreGraphics

class GraphView: UIView {
    
    /// The four varibales to handle the different graph objectts:
    /// The x-axis and y-axis
    /// As well as the dividers for each axis
    var xAxisLayer: CAShapeLayer?
    var yAxisLayer: CAShapeLayer?
    var xAxisDividers: CAShapeLayer?
    var yAxisDividers: CAShapeLayer?
    // The variable to control whether a graph is currently displayed
    var currentGraph: Graph?
    var currentGraphLayer: CAShapeLayer?
    
    var xMarkerDistance = 30.0
    var yMarkerDistance = 30.0
    
    /// Remove the existing layers if they exist and draw the layers
    override func draw(_ rect: CGRect) {
        removeExistingLayers()
        createLayers()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        print(point)
        print(currentGraphLayer?.path?.contains(point))
    }
    
    /// Method to remove the existing layers if they actually exist
    /// Prevents a redraw of the axis, which may show multiple axes 
    /// or dividers
    func removeExistingLayers() {
        xAxisLayer?.removeFromSuperlayer()
        yAxisLayer?.removeFromSuperlayer()
        xAxisDividers?.removeFromSuperlayer()
        yAxisDividers?.removeFromSuperlayer()
        currentGraphLayer?.removeFromSuperlayer()
    }
    
    /// Method to create each of the four layers. Creates them 
    /// based on axis and for the separaters, the distance between each 
    func createLayers() {
        xAxisLayer = drawAxis(xAxis: true)
        yAxisLayer = drawAxis(xAxis: false)
        xAxisDividers = drawAxisMarkers(distance: xMarkerDistance, xAxis: true)
        yAxisDividers = drawAxisMarkers(distance: yMarkerDistance, xAxis: false)
        currentGraphLayer = currentGraph?.display(view: self, xScale: xMarkerDistance, yScale: yMarkerDistance)
    }
    
    /// The main method to draw an axis
    /// Takes an xAxis boolean to manage the direction it is drawn in
    func drawAxis(xAxis: Bool) -> CAShapeLayer {
        let axisLayer = CAShapeLayer()
        // Set the axis color (white on dark mode, black on light)
        axisLayer.strokeColor = UIColor.white.cgColor
        // lineWidth and lineCap stay the same for axis creation
        axisLayer.lineWidth = 2
        axisLayer.lineCap = CAShapeLayerLineCap.square
        self.layer.addSublayer(axisLayer)
        let axisPath = CGMutablePath()
        // Create the two points for the axis line (straight line, orientation depending on the xAxis boolean).
        let point1 = CGPoint(x: xAxis ? 0 : self.bounds.width/2, y: xAxis ? self.bounds.height/2 : 0)
        let point2 = CGPoint(x: xAxis ? self.bounds.width : self.bounds.width/2, y: xAxis ? self.bounds.height/2 : self.bounds.height)
        axisPath.addLines(between: [point1, point2])
        axisLayer.path = axisPath
        return axisLayer
    }
    
    /// The main method to draw the axis markers or numerical markers on the axis
    /// Takes a distance for the distance between each marker and a boolean xAxis to determine the orientation
    func drawAxisMarkers(distance: Double, xAxis: Bool) -> CAShapeLayer {
        let dividerLayer = CAShapeLayer()
        // Set the marker color (white on dark mode, black on light)
        dividerLayer.strokeColor = UIColor.white.cgColor
        // Width and lineCap stay the same, where the width is slightly less than the axis
        dividerLayer.lineWidth = 1.5
        dividerLayer.lineCap = CAShapeLayerLineCap.square
        self.layer.addSublayer(dividerLayer)
        let dividerPath = CGMutablePath()
        var count = Int(xAxis ? self.bounds.width : self.bounds.height) / Int(distance)
        // Make sure the count goes through the origin, so all spacing is even between axes
        if count % 2 != 0 {
            count -= 1
        }
        // Loop from a negative to positive range so the center is sure to be the origin
        for i in (-count/2 + 1)...(count/2 - 1) {
            // Get the centers of both axes
            let centerX = self.bounds.width/2
            let centerY = self.bounds.height/2
            let usedAxisDistance = xAxis ? centerX : centerY
            let constDistance = Double(usedAxisDistance) + distance * Double(i)
            // Create both points for the line and add it to the path
            let point1 = CGPoint(x: xAxis ? constDistance : Double(centerX)-10, y: xAxis ? Double(centerY-10) : constDistance)
            let point2 = CGPoint(x: xAxis ? constDistance : Double(centerX)+10, y: xAxis ? Double(centerY+10) : constDistance)
            dividerPath.addLines(between: [point1, point2])
        }
        dividerLayer.path = dividerPath
        return dividerLayer
    }
}