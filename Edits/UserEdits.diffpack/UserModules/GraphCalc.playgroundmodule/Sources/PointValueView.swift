import UIKit

class PointValueView : UIView {
    
    /// The  x value of the coordinate
    var xValue: Double
    /// The y value of the coordinate
    var yValue: Double
    
    /// The label that shows the coordinate
    let coordinateField = UILabel()
    
    /// The initializer to set the x-value, y-value, and frame of the object
    init(xValue: Double, yValue: Double, frame: CGRect) {
        self.xValue = xValue
        self.yValue = yValue
        super.init(frame: frame)
        self.backgroundColor = UIColor.secondarySystemBackground
    }
    
    /// The function to set the view's border radius and the text field's text
    override func draw(_ rect: CGRect) {
        // Set the border radius for a roudnded view
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        // Get rounded x and y values
        let roundedX = round(xValue * 100)/100
        let roundedY = round(yValue * 100)/100
        // Set the text of the label and size it correctly
        coordinateField.text = "(\(roundedX), \(roundedY))"
        coordinateField.textAlignment = .center
        coordinateField.sizeToFit()
        addSubview(coordinateField)
        // Add constraints
        coordinateField.translatesAutoresizingMaskIntoConstraints = false
        coordinateField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        coordinateField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
