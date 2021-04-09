

import UIKit
import EquationParser

public class GraphingCalculatorViewController : UIViewController {
    let graphView = GraphView()
    let navigationBar = UINavigationBar()
    let graphExpressionField = UITextField()
    var loadingOverlay: UIView?
    var keyboardActive = false
    
    public override func viewDidLoad() {
        // Add the subviews
        view.addSubview(navigationBar)
        view.insertSubview(graphExpressionField, belowSubview: navigationBar)
        view.insertSubview(graphView, belowSubview: graphExpressionField)
        // Initialize UI objects
        initializeNavbar()
        initializeGraphField()
        initializeGraph()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardDidShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.keyboardDidHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !keyboardActive {
            initializeNavbarConstraints()
            initializeGraphInputConstraints()
            initializeGraphConstraints()
            graphView.setNeedsDisplay()
        }
    }
    
    func initializeNavbar() {
        view.backgroundColor = .systemBackground
        // Create the actual item and add both right bar button items
        let navigationItem = UINavigationItem(title: "Graph")
        navigationBar.setItems([navigationItem], animated: false)
    }
    
    func initializeGraphField() {
        graphExpressionField.textAlignment = .center
        graphExpressionField.backgroundColor = .systemBackground
        let finishButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 60))
        let symbolSize = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "checkmark", withConfiguration: symbolSize)
        finishButton.setImage(image, for: .normal)        
        finishButton.addTarget(self, action: #selector(graphExpression), for: .touchUpInside)
        graphExpressionField.rightView = finishButton
        graphExpressionField.rightViewMode = .always
        graphExpressionField.inputView = EntryKeyboard(target: graphExpressionField, showXVariable: true)
        let dismissItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        graphExpressionField.inputAccessoryView = EntryToolbar.shared.createToolbar(for: graphExpressionField, dismissItem: dismissItem)
        resetGraphLabel()
    }
    
    func resetGraphLabel() {
        graphExpressionField.placeholder = "Enter expression Here..."
    }
    
    func initializeGraph() {
        view.backgroundColor = .systemBackground
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func initializeNavbarConstraints() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    func initializeGraphInputConstraints() {
        graphExpressionField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            graphExpressionField.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            graphExpressionField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            graphExpressionField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            graphExpressionField.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    func initializeGraphConstraints() {
        guard let tabBar = tabBarController?.tabBar else {return}
        graphView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            graphView.topAnchor.constraint(equalTo: graphExpressionField.bottomAnchor),
            graphView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            graphView.rightAnchor.constraint(equalTo: view.rightAnchor),
            graphView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }
    
    func showSpinner() {
        let spinnerView = UIView(frame: view.bounds)
        spinnerView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        let ai = UIActivityIndicatorView.init(style: .medium)
        ai.startAnimating()
        ai.center = spinnerView.center
        spinnerView.addSubview(ai)
        view.addSubview(spinnerView)
        loadingOverlay = spinnerView
    }
    
    func removeSpinner() {
        self.loadingOverlay?.removeFromSuperview()
        self.loadingOverlay = nil
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        keyboardActive = true
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        keyboardActive = false
        view.setNeedsLayout()
    }
    
    @objc func graphExpression() {
        updateGraph()
    }
}

extension GraphingCalculatorViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        updateGraph()
        return true
    }
    
    func updateGraph() {
        if let graphStr = graphExpressionField.text {
            self.showSpinner()
            DispatchQueue.global(qos: .userInitiated).async {
                self.graphView.currentGraph = Graph(expression: try! ParseHelper.instance.parseExpression(from: graphStr, numeric: false))
                DispatchQueue.main.sync {
                    self.removeSpinner()
                    self.graphView.setNeedsDisplay()
                }
            }
        }
    }
}
