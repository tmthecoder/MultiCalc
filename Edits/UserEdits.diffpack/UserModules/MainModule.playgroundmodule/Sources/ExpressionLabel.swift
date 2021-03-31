
import UIKit

public class ExpressionLabel : UITextView {
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.font = .systemFont(ofSize: 50)
        self.isScrollEnabled = true
        self.textAlignment = .center
        self.text = "Expression Will Show Here..."
//          self.textColor = .white
        self.textContainer.maximumNumberOfLines = 1
    }
    
}
