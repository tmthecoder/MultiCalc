import UIKit
import PencilKit
import PlaygroundSupport

public class MainView: UIViewController {
    
    var toolPicker: PKToolPicker!
    var canvas: PKCanvasView!
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initializeCanvas()
        initializeToolPicker()
        setupNavBar()
    }
    func setupNavBar() {
        let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        self.view.addSubview(navigationBar)
        let navigationItem = UINavigationItem(title: "Navigation bar")
        let doneBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(donePressed))
        navigationItem.rightBarButtonItem = doneBtn
        navigationBar.setItems([navigationItem], animated: false)
        canvas.addSubview(navigationBar)
    }
    func initializeToolPicker() {
        toolPicker = PKToolPicker()
        toolPicker.addObserver(canvas!)
        toolPicker.setVisible(true, forFirstResponder: canvas)
    }
    func initializeCanvas() {
        canvas = PKCanvasView(frame: self.view.bounds)
        canvas.becomeFirstResponder()
        view.addSubview(canvas)
    }
    
    @objc func donePressed() {
        
    }
}

extension MainView: PKCanvasViewDelegate {
}

extension MainView: PKToolPickerObserver {
    
}

