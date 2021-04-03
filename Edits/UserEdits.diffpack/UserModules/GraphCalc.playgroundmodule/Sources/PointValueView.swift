
import UIKit

class PointValueView : UIView {
    var xValue: Double
    var yValue: Double
    
    let coordinateField = UILabel()
    
    init(xValue: Double, yValue: Double, frame: CGRect) {
        self.xValue = xValue
        self.yValue = yValue
        super.init(frame: frame)
        self.backgroundColor = UIColor.secondarySystemBackground
    }
    
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 15
        self.layer.masksToBounds = true
        let roundedX = round(xValue * 100)/100
        let roundedY = round(yValue * 100)/100
        coordinateField.text = "(\(roundedX), \(roundedY))"
        coordinateField.textAlignment = .center
        coordinateField.sizeToFit()
        addSubview(coordinateField)
        coordinateField.translatesAutoresizingMaskIntoConstraints = false
        coordinateField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        coordinateField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
