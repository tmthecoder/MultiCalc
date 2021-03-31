
import UIKit

public class ExpressionLabel : UITextView {
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.font = .systemFont(ofSize: 40)
        self.isScrollEnabled = false
        self.textAlignment = .center
        self.text = "Type any Expression"
        self.textContainer.maximumNumberOfLines = 1
    }
    
}
