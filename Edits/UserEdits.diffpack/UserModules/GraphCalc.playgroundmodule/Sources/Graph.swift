
import UIKit
import EquationParser

struct Graph {
    let expresssion: SolvableExpression
    var pointData: [Double : Double] = [:]
    let expressionHelper = ExpressionHelper(numeric: false)
    init(expression: SolvableExpression) {
        self.expresssion = expression
    }
    
    private func getPotentialPoints(precision: Double, yValue: Double) -> [Point: Double] {
        var potentialVals: [Point: Double] = [:]
        for (x, y) in pointData {
            if abs(y - yValue) < precision {
                potentialVals[Point(x: x, y: y)] = abs(y - yValue)
            }
        }
        if potentialVals.count == 0 {
            potentialVals = getPotentialPoints(precision: precision * 2, yValue: yValue)
        }
        return potentialVals
    }
    
    private func getActualPoint(pointList: [Point: Double], localizedX: Double) -> Point {
        var reducedPoints: [Double: Point] = [:]
        for (point, _) in pointList {
            reducedPoints[abs(localizedX - point.x)] = point
        }
        let actualPointDist = reducedPoints.keys.sorted(by: <).first!
        return reducedPoints[actualPointDist]!
    }
}

extension Graph {
    
    func getPointY(x: Double) -> Double {
        return expressionHelper.evaluate(expresssion, termValue: x)
    }
    
    func pointForTap(for view: UIView, point: CGPoint, xScale: Double, yScale: Double) -> CGPoint {
        // Get the tapped position and localize it
        let tapY = point.y
        let localY = Double(tapY - view.bounds.height/2) / -yScale
        // Use that with the function inverse to get the x-coordinate and get the actual plane coordinate
        let roundedY = round(localY * 100)/100
        let potentialPoints = getPotentialPoints(precision: 0.1, yValue: roundedY)
        let localizedX = Double(point.x - view.bounds.width/2) / xScale
        let actualPoint = getActualPoint(pointList: potentialPoints, localizedX: localizedX)
        let adjX = Double(view.bounds.width)/2 + (actualPoint.x * xScale)
        return CGPoint(x: adjX, y: Double(tapY))
    }
    mutating func display(for view: UIView, xScale: Double, yScale: Double) -> CAShapeLayer {
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
        let negX = Double(-view.bounds.width/2)/xScale
        let posX = Double(view.bounds.width/2)/xScale
        // Create the point array and path
        var points: [CGPoint] = []
        let path = CGMutablePath()
        // Loop through the potential x coordinates with a stride of 0.01
        for i in stride(from: negX, to: posX, by: 0.01) {
            let x = round(i * 100)/100 // Rounded for precision error
            let y = round(expressionHelper.evaluate(expresssion, termValue: x) * 100)/100
            // If we get an indeterminate value, add the line to show separations in the real graph
            if y.isNaN || y.isInfinite {
                path.addLines(between: points)
                points.removeAll()
                continue
            }
            pointData[x] = y
            let xScale = Double(view.bounds.width)/2 + (x * xScale)
            let yScale = Double(view.bounds.height)/2 + (-y * yScale)
            let point = CGPoint(x: xScale, y: yScale)
            // Plot a small circle if the point is an x or y intercept
            points.append(point)
        }
        // Add the line post-loop
        if points.count > 0 {
            path.addLines(between: points)
        }
        // Add points to the path and create a copy with a stroked width for hit detection
        //        path.addLines(between: points)
        layer.path = path.copy(strokingWithWidth: layer.lineWidth, lineCap: .butt, lineJoin: .bevel, miterLimit: layer.miterLimit)
        // Set the actual graph layer as a sublayer of the wider one
        subLayer.path = path
        return layer
    }
}
