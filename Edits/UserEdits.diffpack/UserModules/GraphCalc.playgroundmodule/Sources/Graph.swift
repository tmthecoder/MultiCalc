
import UIKit
import EquationParser

/// A structure to handle a physcal graph being displayed on a screen
/// Contains the expression and a dataset
struct Graph {
    
    /// The Graph's root expression to get a y value from an x-value
    let expresssion: SolvableExpression
    /// A map of the displayed points
    var pointData: [Double : Double] = [:]
    /// A helper object to evaluate the expression above
    let expressionHelper = ExpressionHelper(numeric: false)
    
    /// The class initializer, which requires an expression to be set
    /// All other instance variables can be derived from the set expression
    init(expression: SolvableExpression) {
        self.expresssion = expression
    }
    
    /// A method to get the potential points a y value can have an x-value of
    /// Especially useful within hit testing for the tracing feature on the graph
    /// Utilizes a set precision and a given y value to detect potential points
    /// Returns a point mapped to its precision
    private func getPotentialPoints(precision: Double, yValue: Double) -> [Point: Double] {
        var potentialVals: [Point: Double] = [:]
        // Get all the points and loop through
        for (x, y) in pointData {
            // Add to the returned map only if they are within precision bounds
            if abs(y - yValue) < precision {
                potentialVals[Point(x: x, y: y)] = abs(y - yValue)
            }
        }
        // If the search returns nothing, call a new search with a doubled precision
        if potentialVals.count == 0 {
            potentialVals = getPotentialPoints(precision: precision * 2, yValue: yValue)
        }
        return potentialVals
    }
    
    /// A method to derive the actual x-point from a given value and precision set
    /// Uses the precision set and finds the closest point with the right x bounds of the hit region
    /// Returns a Point with the x and y values
    private func getActualPoint(pointList: [Point: Double], localizedX: Double) -> Point {
        var reducedPoints: [Double: Point] = [:]
        for (point, _) in pointList {
            reducedPoints[abs(localizedX - point.x)] = point
        }
        let actualPointDist = reducedPoints.keys.sorted(by: <).first!
        return reducedPoints[actualPointDist]!
    }
}

/// An extension for all publicly available methods in the Grpah object
extension Graph {
    
    /// A method to get a y value from a given x value
    func getPointY(x: Double) -> Double {
        return expressionHelper.evaluate(expresssion, termValue: x)
    }
    
    /// A method to get the point for a given point on the Window (from a user's tap)
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
    
    /// A fucntion to trace display the current graph object on the given view
    /// Takes a view with its x and y scale for a single digit to return a line with window-localized points
    /// Returns a CAShapeLayer with the graph and an extended hit traced portion (for user taps)
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
        // Clear the stored points variable
        pointData = [:]
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
        layer.path = path.copy(strokingWithWidth: layer.lineWidth, lineCap: .butt, lineJoin: .bevel, miterLimit: layer.miterLimit)
        // Set the actual graph layer as a sublayer of the wider one
        subLayer.path = path
        return layer
    }
}
