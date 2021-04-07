

import UIKit
import EquationParser

public class GraphingCalculatorViewController : UIViewController {
    let graphView = GraphView()
    let navigationBar = UINavigationBar()
    let graphInputField = UITextField()
    
    public override func viewDidLoad() {
        // Add the subviews
        view.addSubview(navigationBar)
        view.insertSubview(graphInputField, belowSubview: navigationBar)
        view.insertSubview(graphView, belowSubview: graphInputField)
        // Initialize UI objects
        initializeNavbar()
        initializeGraphField()
        initializeGraph()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initializeNavbarConstraints()
        initializeGraphInputConstraints()
        initializeGraphConstraints()
        graphView.currentGraph = Graph(expression: ParseHelper.instance.parseExpression(from: "x^2 + 1", numeric: false))
        graphView.setNeedsDisplay()
    }
    
    func initializeNavbar() {
        view.backgroundColor = .systemBackground
        // Create the actual item and add both right bar button items
        let navigationItem = UINavigationItem(title: "Graph")
        navigationBar.setItems([navigationItem], animated: false)
    }
    
    func initializeGraphField() {
        graphInputField.inputView = EntryKeyboard(target: graphInputField, showXVariable: true)
        graphInputField.backgroundColor = .systemBackground
        setDoneOnKeyboard()
        graphInputField.textAlignment = .center
        graphInputField.placeholder = "Enter Expression Here..."
    }
    
    func initializeGraph() {
        view.backgroundColor = .systemBackground
    }
    
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        func createCustomBarButton(operation: String, value: String? = nil) -> UIBarButtonItem {
            let value = value ?? operation
            let keyButton = KeyButton(type: .system)
            keyButton.value = value
            keyButton.setAttributedTitle(NSAttributedString(string: operation, attributes: [.font : UIFont.systemFont(ofSize: 30)]), for: .normal)
            keyButton.addTarget(self, action: #selector(operationClicked(_:)), for: .touchUpInside)
            return UIBarButtonItem(customView: keyButton)
        }
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        // Create all of the operation items and center them
        keyboardToolbar.items = [
            flexBarButton, flexBarButton, flexBarButton,
            flexBarButton, flexBarButton,
            createCustomBarButton(operation: "+"),
            flexBarButton,
            createCustomBarButton(operation: "-"),
            flexBarButton,
            createCustomBarButton(operation: "x", value: "*"),
            flexBarButton,
            createCustomBarButton(operation: "÷"),
            flexBarButton,
            createCustomBarButton(operation: "^"),
            flexBarButton, flexBarButton ,flexBarButton,
            flexBarButton,doneBarButton
        ]
        self.graphInputField.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func operationClicked(_ sender: KeyButton) {
        if graphInputField.text != nil {
            graphInputField.text! += sender.value
        }
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
        graphInputField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            graphInputField.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            graphInputField.leftAnchor.constraint(equalTo: view.leftAnchor),
            graphInputField.rightAnchor.constraint(equalTo: view.rightAnchor),
            graphInputField.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    func initializeGraphConstraints() {
        guard let tabBar = tabBarController?.tabBar else {return}
        graphView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            graphView.topAnchor.constraint(equalTo: graphInputField.bottomAnchor),
            graphView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            graphView.rightAnchor.constraint(equalTo: view.rightAnchor),
            graphView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }
}
