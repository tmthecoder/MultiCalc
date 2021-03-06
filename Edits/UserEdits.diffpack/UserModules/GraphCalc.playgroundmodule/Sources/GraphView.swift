import UIKit

/// A class create a coordinate plane and show a graph on top of said coordinate plane
class GraphView: UIView {
    
    /// The current layer that holds the x-axis
    var xAxisLayer: CAShapeLayer?
    /// The current layer that holds the y-axis
    var yAxisLayer: CAShapeLayer?
    /// The current layer that holds the dividers for x-axis digits
    var xAxisDividers: CAShapeLayer?
    /// The current layer that holds the dividers for  y-axis digits
    var yAxisDividers: CAShapeLayer?
    
    /// The current graph that should be shown
    var currentGraph: Graph?
    /// The shape layer of the current graph
    var currentGraphLayer: CAShapeLayer?
    
    /// The distance between each x-axis divider
    var xMarkerDistance = 30.0
    /// The distance between each y-axis divider
    var yMarkerDistance = 30.0
    
    /// Array of UILabels currently being used to display a numerical marker
    var markerValues: [UILabel] = []
    
    /// The point currently shown on a trace
    var currentPointView: PointValueView?
    
    /// Remove the existing layers if they exist and draw the layers
    override func draw(_ rect: CGRect) {
        removePointView()
        removeExistingLayers()
        createLayers()
    }
    
    /// A method to redraw only the graph and not any of the axes or dividers
    func redrawGraph() {
        currentGraphLayer?.removeFromSuperlayer()
        currentGraphLayer = currentGraph?.display(for: self, xScale: xMarkerDistance, yScale: yMarkerDistance)
        layer.addSublayer(currentGraphLayer!)
    }
    
    /// Start the tracing process and show the traced x and y coordinate values on the graph
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the point that was hit and make sure the point is within the graph bounds
        guard let point = touches.first?.location(in: self),
              let currentGraph = currentGraph else {return}
        if currentGraphLayer?.path == nil || !currentGraphLayer!.path!.contains(point) {
            removePointView()
            return
        }
        // Get the adjusted point's x and y values (the one on the actual line)
        let adjPoint = currentGraph.pointForTap(for: self, point: point, xScale: xMarkerDistance, yScale: yMarkerDistance)
        // Transform the values to a localized version
        let xValue = (Double(adjPoint.x) - Double(self.bounds.width/2)) / xMarkerDistance
        let yValue = (Double(adjPoint.y) - Double(self.bounds.height/2)) / -yMarkerDistance
        // Animate to the position if the view is already shown or create a new one if not
        if let currentPointView = currentPointView {
            UIView.animate(withDuration: 0.5) {
                currentPointView.xValue = xValue
                currentPointView.yValue = yValue
                currentPointView.setNeedsDisplay()
                currentPointView.frame = CGRect(x: adjPoint.x + 15, y: adjPoint.y + 15, width: 120, height: 50)
            }
        } else {
            let frame = CGRect(x: adjPoint.x+15, y: adjPoint.y+15, width: 120, height: 50)
            currentPointView = PointValueView(xValue: xValue, yValue: yValue, frame: frame)
            guard let currentPointView = currentPointView else {return}
            addSubview(currentPointView)
        }
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
        removeCounters()
    }
    
    /// Method to create each of the four layers.
    /// Creates them based on axis and for the separaters, the distance between each
    func createLayers() {
        // Create Axes
        xAxisLayer = drawAxis(xAxis: true)
        yAxisLayer = drawAxis(xAxis: false)
        // Create markers for axes
        xAxisDividers = drawAxisMarkers(distance: xMarkerDistance, xAxis: true)
        yAxisDividers = drawAxisMarkers(distance: yMarkerDistance, xAxis: false)
        // Create the counters for both axes
        addCounters(increment: 1, xAxis: true)
        addCounters(increment: 1, xAxis: false)
        // Create the current graph
        currentGraphLayer = currentGraph?.display(for: self, xScale: xMarkerDistance, yScale: yMarkerDistance)
    }
    
    /// The main method to draw an axis
    /// Takes an xAxis boolean to manage the direction it is drawn in
    func drawAxis(xAxis: Bool) -> CAShapeLayer {
        let axisLayer = CAShapeLayer()
        // Set the axis color (white on dark mode, black on light)
        axisLayer.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white.cgColor : UIColor.black.cgColor
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
        dividerLayer.strokeColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white.cgColor : UIColor.black.cgColor
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
        // Get the centers of both axes
        let centerX = self.bounds.width/2
        let centerY = self.bounds.height/2
        let usedAxisDistance = xAxis ? centerX : centerY
        // Loop from a negative to positive range so the center is sure to be the origin
        for i in (-count/2 + 1)...(count/2 - 1) {
            let constDistance = Double(usedAxisDistance) + distance * Double(i)
            // Create both points for the line and add it to the path
            let point1 = CGPoint(x: xAxis ? constDistance : Double(centerX)-10, y: xAxis ? Double(centerY-10) : constDistance)
            let point2 = CGPoint(x: xAxis ? constDistance : Double(centerX)+10, y: xAxis ? Double(centerY+10) : constDistance)
            dividerPath.addLines(between: [point1, point2])
        }
        dividerLayer.path = dividerPath
        return dividerLayer
    }
    
    /// Method to show the correct counter value at the right position.
    /// Shown values based on the given increments
    func addCounters(increment: Double, xAxis: Bool) {
        var count = Int(xAxis ? self.bounds.width : self.bounds.height) / Int(xAxis ? xMarkerDistance : yMarkerDistance)
        // Make sure the count goes through the origin, so all spacing is even between axes
        if count % 2 != 0 {
            count -= 1
        }
        // Get the centers of both axes
        let centerX = self.bounds.width/2
        let centerY = self.bounds.height/2
        let usedAxisDistance = xAxis ? centerX : centerY
        // Loop from a negative to positive range so the center is sure to be the origin
        for i in (-count/2 + 1)...(count/2 - 1) {
            if i % 5 == 0  && i != 0{
                // Get the distance each textual marker will be placed at
                let constDistance = Double(usedAxisDistance) + (xAxis ? xMarkerDistance : yMarkerDistance) * Double(i)
                // Create an initial frame without text sizing in mind
                let initialFrame = CGRect(x: xAxis ? constDistance : Double(centerX + 15), y: xAxis ? Double(centerY + 15) : constDistance, width: 50, height: 30)
                let label = UILabel(frame: initialFrame)
                label.text = "\(increment * Double(i))"
                if i < 0 {
                    label.text!+=" " // Add a trailing space for alignment of negatives to the marker
                }
                // Size the label and create the final frame based off of the positions and height/width offsets
                label.sizeToFit()
                let finalX = xAxis ? label.frame.minX - label.frame.width/2 : label.frame.minX
                let finalY = xAxis ? label.frame.minY : label.frame.minY - label.frame.height/2
                let finalFrame = CGRect(x: finalX, y: finalY, width: label.frame.width, height: label.frame.height)
                label.frame = finalFrame
                // Add the label to the array (for removal when/if needed) and as a subview
                markerValues.append(label)
                addSubview(label)
            }
        }
    }
    
    /// Method to remove the counters from their stored array
    /// Loops through and removes each from the superview (this view)
    func removeCounters() {
        for label in markerValues {
            label.removeFromSuperview()
        }
    }
    
    /// A method to remve the current point view if existing
    func removePointView() {
        currentPointView?.removeFromSuperview()
        currentPointView = nil
    }
}
