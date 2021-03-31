import UIKit
import PencilKit
import PlaygroundSupport

public class MainViewController: UIViewController {
    
    var toolPicker: PKToolPicker!
    var canvas: PKCanvasView!
    var ocrHandler: OCRHandler!
    var expressionLabel = ExpressionLabel()
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupNavBar()
        setupLabel()
        initializeOCR()
        initializeCanvas()
        initializeToolPicker()
    }
    func setupNavBar() {
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        view.backgroundColor = .systemBackground
        self.view.addSubview(navigationBar)
        let navigationItem = UINavigationItem(title: "DrawCalc")
        let clearButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.trash, target: nil, action: #selector(clearCanvas))
        navigationItem.rightBarButtonItem = clearButton
        navigationBar.setItems([navigationItem], animated: false)
        view.addSubview(navigationBar)
    }
    func setupLabel() {
        expressionLabel.frame = CGRect(x: 0, y: 45, width: self.view.bounds.width, height: 70)
        self.view.addSubview(expressionLabel)
    }
    func initializeToolPicker() {
        toolPicker = PKToolPicker()
        toolPicker.addObserver(canvas!)
        toolPicker.setVisible(true, forFirstResponder: canvas)
    }
    func initializeCanvas() {
        let frame = CGRect(x: 0, y: 130, width: self.view.bounds.width, height: self.view.bounds.height-115)
        canvas = PKCanvasView(frame: frame)
        if self.traitCollection.userInterfaceStyle == .dark {
            canvas.backgroundColor = .clear 
        }
        canvas.delegate = ocrHandler
        canvas.becomeFirstResponder()
        view.addSubview(canvas)
    }
    
    func initializeOCR() {
        ocrHandler = OCRHandler(onResult: onOCRResult)
    }
    
    func onOCRResult(result: String) {
        DispatchQueue.main.sync {
            expressionLabel.text = result
        }
    }
    
    @objc func clearCanvas() {
        canvas.drawing = PKDrawing()
        expressionLabel.text = ""
    }
}

