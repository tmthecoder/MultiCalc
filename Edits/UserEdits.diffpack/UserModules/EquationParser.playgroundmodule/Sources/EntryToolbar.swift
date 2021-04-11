import UIKit

/// A class to handle a button on the toolbar (all operations)
class ToolbarButton : KeyButton {
    /// The textfeld assosiated with the toolbar
    var textField: UITextField?
}

/// A class to handle the creation of the Toolbar that shows the operations for user entry
public class EntryToolbar {
    
    /// The shared instance to call the create methods
    public static let shared = EntryToolbar()
    
    /// The method to create the toolbar that shows the addition, subtraction, multiplication, disivion, and exponent operations
    public func createToolbar(for textfield: UITextField, dismissItem: UIBarButtonItem) -> UIToolbar {
        // Create a toolbar and size it
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        /// An inner method to create the operation's associated button
        func createCustomBarButton(operation: String, value: String? = nil) -> UIBarButtonItem {
            // Set a value for the button to use for entry on the textfield
            let value = value ?? operation
            let toolbarButton = ToolbarButton(type: .system)
            // Set the button attributes
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
    
    /// A method to handle an operation item being clicked, appending its value to the textfield
    /// Needs a ToolbarButton object as the sender to get the correct value and textfield
    @objc func operationClicked(_ sender: ToolbarButton) {
        if let textfield = sender.textField, textfield.text != nil {
            textfield.text! += sender.value
        }
    }
}
