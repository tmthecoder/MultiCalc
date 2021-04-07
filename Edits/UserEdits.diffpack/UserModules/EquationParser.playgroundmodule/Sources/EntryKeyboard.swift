import UIKit
import Foundation

/// A class to store the key's value to add when clucked
public class KeyButton : UIButton {
    /// The value to add to the textfield when pressed
    public var value: String = ""
}

/// The keyboard object view class
public class EntryKeyboard: UIView {
    
    /// The target input field
    weak var target: UIKeyInput?
    /// The setter to decide whether to show the x variable or not
    var showXVariable: Bool
    
    /// The buttons on the top row (open and closed parentheses and the backspace button)
    var topRow: [KeyButton] {
        // Add the text parentheses buttons
        var topRow: [KeyButton] = ["(", ")"].map {
            let button = createButton(title: "\($0)")
            button.addTarget(self, action: #selector(entryButtonClicked(_:)), for: .touchUpInside)
            return button
        }
        // Add the image made backspace button
        topRow.append(backspaceButton)
        return topRow
    }
    
    /// All Numeric buttons ranging from 1-9 (0 is added in the bottom row separately)
    var numericButtons: [KeyButton] {
        return (1...9).map {
            // Create each button with the iterated value
            let button = createButton(title: "\($0)")
            button.addTarget(self, action: #selector(entryButtonClicked(_:)), for: .touchUpInside)
            return button
        }
    }
    
    /// All buttons on the bottom row (The decimal, 0, and x variable if applicable)
    var bottomRow: [KeyButton] {
        // Add the known two buttons (decimal and 0)
        var bottomRow: [KeyButton] = [".", "0"].map {
            let button = createButton(title: "\($0)")
            button.addTarget(self, action: #selector(entryButtonClicked(_:)), for: .touchUpInside)
            return button
        }
        // Add the x variable if set, or create a blank button
        bottomRow.append(showXVariable ? variableButton : KeyButton())
        return bottomRow
    }
    
    /// The button created to show if the showXVariable is set to true
    var variableButton: KeyButton {
        let button = createButton(title: "x")
        button.addTarget(self, action: #selector(entryButtonClicked(_:)), for: .touchUpInside)
        return button
    }
    
    /// The button created for the backspace or delete operation
    var backspaceButton: KeyButton {
        // Create with an image (soecifically the delete.left SFSymbol)
        let backspaceImage = UIImage(systemName: "delete.left")!
        let button = createImageButton(image: backspaceImage)
        button.addTarget(self, action: #selector(backspaceClicked), for: .touchUpInside)
        return button
    }
    
    /// A method to create a textual button with a potential font specification if desired
    func createButton(title: String, fontAttrubute: UIFont = .systemFont(ofSize: 20)) -> KeyButton {
        // Create a KeyButton object and set the title color and font attributes
        let button = KeyButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.setAttributedTitle(NSAttributedString(string: title, attributes: [.font: fontAttrubute]), for: .normal)
        button.accessibilityTraits = [.keyboardKey]
        button.value = title
        return button
    }
    
    /// A method to create a button with an image instead of text
    func createImageButton(image: UIImage) -> KeyButton {
        // Set the button's image
        let button = KeyButton(type: .system)
        button.setImage(image, for: .normal)
        button.accessibilityTraits = [.keyboardKey]
        return button
    }
    
    /// The class initializer, sets the target and whether the x variable should be shown
    public init(target: UIKeyInput, showXVariable: Bool = false) {
        self.target = target
        self.showXVariable = showXVariable
        super.init(frame: .zero)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        configureView()
    }
    
    /// Configures the keyboard's stack view with all keys
    func configureView() {
        // Create the parent stack view
        let stackView = createStackView(axis: .vertical)
        stackView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        stackView.frame = bounds
        addSubview(stackView)
        // Create the substack for the top row
        let topRowStack = createStackView(axis: .horizontal)
        stackView.addArrangedSubview(topRowStack)
        for button in self.topRow {
            topRowStack.addArrangedSubview(button)
        }
        // Create all three rows of numebers from 1 through 9
        for col in 0..<3 {
            let horStackView = createStackView(axis: .horizontal)
            stackView.addArrangedSubview(horStackView)
            for row in 0..<3 {
                horStackView.addArrangedSubview(numericButtons[col * 3 + row])
            }
        }
        // Cfeate the substack for the bottom row
        let bottomRowStack = createStackView(axis: .horizontal)
        stackView.addArrangedSubview(bottomRowStack)
        for button in bottomRow {
            bottomRowStack.addArrangedSubview(button)
        }
    }
    
    /// A method to create stack views with a set axis
    func createStackView(axis: NSLayoutConstraint.Axis) -> UIStackView {
        // Create the view, set the axis and fill
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// A method to handle all text entry to the field once the entry buttons (all except backspace) are clicked
    @objc func entryButtonClicked(_ sender: KeyButton) {
        target?.insertText(sender.value)
    }
    
    /// A method to remove the last element via a backspace
    @objc func backspaceClicked() {
        target?.deleteBackward()
    }
}
