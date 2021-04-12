import UIKit

public class IntroView : UIView {
    public override func draw(_ rect: CGRect) {
        let label = UILabel()
        label.text = "hey"
        label.textColor = .white
        addSubview(label)
        label.sizeToFit()
    }
}
