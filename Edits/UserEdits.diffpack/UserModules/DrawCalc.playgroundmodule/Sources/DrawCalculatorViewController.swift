import UIKit
import PencilKit
import EquationParser

/// The UIViewController for the actual Draw Calculator View
public class DrawCalculatorViewController: UIViewController {
    
    // All the class's used UI components
    var canvas = PKCanvasView()
    var navigationBar = UINavigationBar()
    var expressionLabel = UITextView()
    
    // The handler for OCR operations
    var ocrHandler: OCRHandler!
    
    /// Setup all of the needed items for the canvas (UI and OCR)
    /// Items include a navbar, canvas, and a label for UI along with the OCR and its listener
    public override func viewDidLoad() {
        // Add all subviews
        view.addSubview(canvas)
        view.addSubview(navigationBar)
        view.addSubview(expressionLabel)
        // OCR initialization
        initializeOCR()
        // UI Initialization
        setupNavBar()
        initializeLabel()
        initializeCanvas()
        resetLabel()
    }
    
    /// Re-initialize constraints when the layout changes (bounds or expansion)
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initializeConstraints()
    }
    
    /// A Method to setup the navigation bar and its shown buttons
    /// Currently sets the title and adds the canvas clear and erase buttons
    func setupNavBar() {
        view.backgroundColor = .systemBackground
        // Create the actual item and add both right bar button items
        let navigationItem = UINavigationItem(title: "Draw")
        navigationItem.rightBarButtonItems = [createTrashItem(), createEraseItem()]
        navigationBar.setItems([navigationItem], animated: false)
//          if navigationBar.superview == nil {
//              view.addSubview(navigationBar)
//          }
    }
    
    /// A method to create the item for the canvas clear button
    /// Uses the trash SFSymbol
    func createTrashItem() -> UIBarButtonItem {
        let button = createButtonItem(image: UIImage(systemName: "trash")!)
        button.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    /// A method to create the erase/pen tool toggle
    /// Uses the scribble SFSymbol and erase material icon
    func createEraseItem() -> UIBarButtonItem {
        let highlighted = UIImage(systemName: "scribble")
        let button = createButtonItem(image: UIImage(named: "erase")!.withTintColor(.systemBlue), selected: highlighted)
        button.addTarget(self, action: #selector(toggleEraser(sender:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    /// A method to create a generic button with a given image and potential selected image 
    func createButtonItem(image: UIImage, selected: UIImage? = nil) -> UIButton {
        let button = UIButton()
        button.setImage(image, for: .normal)
        if let selected = selected {
            button.setImage(selected, for: .selected)
        }
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        return button
    }
    
    /// A method to initialize the drawable PKCanvas with the OCRHandler as its delegate
    /// Sets the default tool as well
    func initializeCanvas() {
        canvas.backgroundColor = .systemBackground 
        canvas.delegate = ocrHandler
        canvas.becomeFirstResponder()
        canvas.drawingPolicy = .anyInput
        canvas.tool = PKInkingTool(.pen, color: .blue, width: 20)
//          if canvas.superview == nil {
//              view.addSubview(canvas)
//          }
    }
    
    /// A method to initialize the top expression label
    func initializeLabel() {
        expressionLabel.font = .systemFont(ofSize: 25)
        expressionLabel.isScrollEnabled = false
        expressionLabel.textAlignment = .center
        expressionLabel.isEditable = false
        expressionLabel.textContainer.maximumNumberOfLines = 1
//          if expressionLabel.superview == nil {
//              view.addSubview(expressionLabel)
//          }
    }
    
    /// A method to initialize the OCR handler for this ViewController
    func initializeOCR() {
        ocrHandler = OCRHandler(onResult: onOCRResult)
    }
    
    /// A method to initialize all of the UI constraints on this ViewController
    func initializeConstraints() {
        // Get the TabBar
        let tabBar = tabBarController!.tabBar
        // Set up all constraints for the navigation bar
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 45)
        ])
        // Setup all constraints for the expressionLabel
        expressionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            expressionLabel.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            expressionLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            expressionLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            expressionLabel.heightAnchor.constraint(equalToConstant: 80)
        ])
        // Setup all constraints for the canvas
        canvas.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            canvas.topAnchor.constraint(equalTo: expressionLabel.bottomAnchor),
            canvas.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            canvas.leftAnchor.constraint(equalTo: view.leftAnchor),
            canvas.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    /// A callback method with a given OCR Result
    /// TODO Parse the result into an Expression and provide a solution
    func onOCRResult(result: String) {
        //          Expression.parseOperations(expressionString: result)
        DispatchQueue.main.sync {
            if canvas.drawing.strokes.count == 0 {return}
            expressionLabel.textColor = self.traitCollection.userInterfaceStyle == .dark ? .lightText : .darkText
            expressionLabel.font = .systemFont(ofSize: 50)
            expressionLabel.text = result
            // TODO Sanitize result
            print(ParseHelper.instance.parseExpression(from: sanitizeResult(result), numeric: true))
        }
    }
    
    // TODO Test
    func sanitizeResult(_ result: String) -> String {
        var formatted = result.lowercased()
        formatted = formatted.replacingOccurrences(of: "x", with: "*")
        formatted = formatted.replacingOccurrences(of: "÷", with: "/")
        return formatted
    }
    
    /// A convenience method to reset the label to its placeholder type state
    func resetLabel() {
        // Changes the fontsize and color while setting it to the default string
        expressionLabel.font = .systemFont(ofSize: 30)
        expressionLabel.textAlignment = .center
        expressionLabel.textColor = .placeholderText
        expressionLabel.text = "Write Problem Below"
    }
    
    /// A method to clear the current drawing on the canvas
    @objc func clearCanvas() {
        canvas.drawing = PKDrawing()
        resetLabel()
    }
    
    /// A method to toggle between eraser and pen functionality
    @objc func toggleEraser(sender: UIButton) {
        // Change the selected state and the tool
        sender.isSelected.toggle()
        if sender.isSelected {
            canvas.tool = PKEraserTool(.bitmap)
        } else {
            canvas.tool = PKInkingTool(.pen, color: .blue, width: 20)
        }
    }
}

