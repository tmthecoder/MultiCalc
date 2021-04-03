
import UIKit

struct Graph {
    let expresssion: String
    init(expression: String) {
        self.expresssion = expression
    }
    func getPointY(x: Double) -> Double {
        return x * x;
    }
    func display(view: UIView, xScale: Double, yScale: Double) -> CAShapeLayer {
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
        // Get the points with a stride of 0.01 to add to the path
        let points: [CGPoint] = stride(from: -10, to: 10, by: 0.01).map {
            let x = round($0 * 100)/100 // Rounded for precision errors
            let y = (x + 1) * (x - 1)
            let xScale = Double(view.bounds.width)/2 + (x * xScale)
            let yScale = Double(view.bounds.height)/2 + (-y * yScale)
            let point = CGPoint(x: xScale, y: yScale)
            // Plot a small circle if the point is an x or y intercept
            if x == 0 || y == 0 { 
                // Create the circle layer and make a path for it
                let circleLayer = CAShapeLayer()
                circleLayer.strokeColor = UIColor.systemGray.cgColor
                circleLayer.fillColor = UIColor.systemGray.cgColor
                layer.addSublayer(circleLayer)
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
