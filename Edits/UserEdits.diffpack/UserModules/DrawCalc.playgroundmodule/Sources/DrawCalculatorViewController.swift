import UIKit
import PencilKit
import PlaygroundSupport

public class DrawCalculatorViewController: UIViewController {
    
    var toolPicker: PKToolPicker!
    var canvas: PKCanvasView!
    var ocrHandler: OCRHandler!
    var expressionLabel = ExpressionLabel()
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initializeOCR()
        setupNavBar()
        initializeCanvas()
        setupLabel()
    }
    func setupNavBar() {
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 45))
        view.backgroundColor = .systemBackground
        self.view.addSubview(navigationBar)
        let navigationItem = UINavigationItem(title: "DrawCalc")
        navigationItem.rightBarButtonItems = [createTrashItem(), createEraseItem()]
        navigationBar.setItems([navigationItem], animated: false)
        view.addSubview(navigationBar)
    }
    
    func createTrashItem() -> UIBarButtonItem {
        let button = createButtonItem(image: UIImage(systemName: "trash")!)
        button.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    func createEraseItem() -> UIBarButtonItem {
        let highlighted = UIImage(systemName: "scribble")
        let button = createButtonItem(image: UIImage(named: "erase")!.withTintColor(.systemBlue), selected: highlighted)
        button.addTarget(self, action: #selector(toggleEraser(sender:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    func createButtonItem(image: UIImage, selected: UIImage? = nil) -> UIButton {
        let button = UIButton()
        button.setImage(image, for: .normal)
        if let selected = selected {
            button.setImage(selected, for: .selected)
        }
        button.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        return button
    }
    func setupLabel() {
        expressionLabel = ExpressionLabel()
        expressionLabel.frame = CGRect(x: 0, y: 45, width: self.view.bounds.width, height: 80)
        resetLabel()
        self.view.addSubview(expressionLabel)
    }
    func initializeCanvas() {
        let frame = CGRect(x: 0, y: 125, width: self.view.bounds.width, height: self.view.bounds.height-127)
        canvas = PKCanvasView(frame: frame)
        canvas.backgroundColor = .clear 
        canvas.delegate = ocrHandler
        canvas.becomeFirstResponder()
        canvas.tool = PKInkingTool(.pen, color: .blue, width: 20)
        view.addSubview(canvas)
        canvas.sizeToFit()
    }
    
    func initializeOCR() {
        ocrHandler = OCRHandler(onResult: onOCRResult)
    }
    
    func onOCRResult(result: String) {
        DispatchQueue.main.sync {
            expressionLabel.textColor = self.traitCollection.userInterfaceStyle == .dark ? .lightText : .darkText
            expressionLabel.font = .systemFont(ofSize: 50)
            expressionLabel.text = result
        }
    }
    
    func resetLabel() {
        expressionLabel.font = .systemFont(ofSize: 30)
        expressionLabel.textColor = .placeholderText
        expressionLabel.text = "Write Problem Below"
    }
    
    @objc func clearCanvas() {
        canvas.drawing = PKDrawing()
        resetLabel()
    }
    
    @objc func toggleEraser(sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            canvas.tool = PKEraserTool(.bitmap)
        } else {
            canvas.tool = PKInkingTool(.pen, color: .blue, width: 20)
        }
    }
}

