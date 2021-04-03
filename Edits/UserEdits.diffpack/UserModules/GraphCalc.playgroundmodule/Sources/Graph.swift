
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
            let x = $0
            let y = x * x
            let xScale = Double(view.bounds.width)/2 + (x * xScale)
            let yScale = Double(view.bounds.height)/2 + (-y * yScale)
            return CGPoint(x: xScale, y: yScale)
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
