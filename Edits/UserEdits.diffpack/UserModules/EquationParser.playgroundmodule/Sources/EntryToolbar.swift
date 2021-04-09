
import UIKit

class ToolbarButton : KeyButton {
    var textField: UITextField?
}

public class EntryToolbar {
    
    public static let shared = EntryToolbar()
    
    public func createToolbar(for textfield: UITextField, dismissItem: UIBarButtonItem) -> UIToolbar {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        func createCustomBarButton(operation: String, value: String? = nil) -> UIBarButtonItem {
            let value = value ?? operation
            let toolbarButton = ToolbarButton(type: .system)
            toolbarButton.value = value
            toolbarButton.textField = textfield
            toolbarButton.setAttributedTitle(NSAttributedString(string: operation, attributes: [.font : UIFont.systemFont(ofSize: 30)]), for: .normal)
            toolbarButton.addTarget(self, action: #selector(operationClicked(_:)), for: .touchUpInside)
            return UIBarButtonItem(customView: toolbarButton)
        }
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Create all of the operation items and center them
        keyboardToolbar.items = [
            flexBarButton, flexBarButton, flexBarButton,
            flexBarButton,
            createCustomBarButton(operation: "+"),
            flexBarButton,
            createCustomBarButton(operation: "-"),
            flexBarButton,
            createCustomBarButton(operation: "x", value: "*"),
            flexBarButton,
            createCustomBarButton(operation: "÷"),
            flexBarButton,
            createCustomBarButton(operation: "^"),
            flexBarButton, flexBarButton, flexBarButton,
            dismissItem
        ]
        return keyboardToolbar
    }
    
    @objc func operationClicked(_ sender: ToolbarButton) {
        if let textfield = sender.textField, textfield.text != nil {
            textfield.text! += sender.value
        }
    }
    
}
