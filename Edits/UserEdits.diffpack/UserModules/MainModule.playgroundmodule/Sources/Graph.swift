import UIKit

struct Graph {
    let expresssion: String
    init(expression: String) {
        self.expresssion = expression
    }
    func display(view: UIView, xScale: Double, yScale: Double) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.systemBlue.cgColor
        layer.lineWidth = 2
        layer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(layer)
        let points: [CGPoint] = stride(from: -10, to: 10, by: 0.01).map {
            let x = $0
            let y = x * x
            let xScale = Double(view.bounds.width)/2 + (x * xScale)
            let yScale = Double(view.bounds.height)/2 + (-y * yScale)
            return CGPoint(x: xScale, y: yScale)
        }
        let path = CGMutablePath()
        path.addLines(between: points)
        path.closeSubpath()
        layer.path = path
        return layer
    }
}
