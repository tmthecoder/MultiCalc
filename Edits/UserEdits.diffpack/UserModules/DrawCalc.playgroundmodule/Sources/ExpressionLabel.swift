
import UIKit

public class ExpressionLabel : UITextView {
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.font = .systemFont(ofSize: 25)
        self.isScrollEnabled = false
        self.textAlignment = .center
        self.isEditable = false
        self.textContainer.maximumNumberOfLines = 1
    }
    
}
