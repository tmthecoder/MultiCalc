
import UIKit

struct Graph {
    let expresssion: String
    init(expression: String) {
        self.expresssion = expression
    }
    func getPointY(x: Double) -> Double {
        return x * x;
    }
    func pointForTap(for view: UIView, point: CGPoint, xScale: Double, yScale: Double) -> CGPoint{
        let tapY = round(point.y * 100)/100
        let localY = Double(tapY - view.bounds.height/2) / -yScale
        print(localY)
        let localX = sqrt(max(localY, 0))
        let adjX = Double(view.bounds.width)/2 + (localX * xScale)
        print(adjX)
        return CGPoint(x: adjX, y: Double(tapY))
    }
    func display(for view: UIView, xScale: Double, yScale: Double) -> CAShapeLayer {
        // Create a clear outer layer with a greater width for hit-detectiom
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.clear.cgColor
        layer.lineWidth = 30
        layer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(layer)
        // Create a thinner layer where the actual graph will show
        let subLayer = CAShapeLayer()
        subLayer.strokeColor = UIColor.blue.cgColor
        subLayer.lineWidth = 3
        subLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(subLayer)
        // Create the circle layer for the intercept markings
        let circleLayer = CAShapeLayer()
        circleLayer.strokeColor = UIColor.systemGray.cgColor
        circleLayer.fillColor = UIColor.systemGray.cgColor
        layer.addSublayer(circleLayer)
        // Get the points with a stride of 0.01 to add to the path
        let points: [CGPoint] = stride(from: -10, to: 10, by: 0.01).map {
            let x = round($0 * 100)/100 // Rounded for precision errors
            let y = x * x
            let xScale = Double(view.bounds.width)/2 + (x * xScale)
            let yScale = Double(view.bounds.height)/2 + (-y * yScale)
            let point = CGPoint(x: xScale, y: yScale)
            // Plot a small circle if the point is an x or y intercept
            if x == 0 || y == 0 { 
                // Add a path to the circle layer for intercepts
                let circlePath = UIBezierPath(arcCenter: point, radius: 7, startAngle: 0, endAngle: 2.0 * CGFloat.pi, clockwise: true)
                circleLayer.path = circlePath.cgPath
            }
            return point
        }
        // Add points to the path and create a copy with a stroked width for hit detection
        let path = CGMutablePath()
        path.addLines(between: points)
        layer.path = path.copy(strokingWithWidth: layer.lineWidth, lineCap: .butt, lineJoin: .bevel, miterLimit: layer.miterLimit)
        // Set the actual graph layer as a sublayer of the wider one
        subLayer.path = path
        return layer
    }
}
