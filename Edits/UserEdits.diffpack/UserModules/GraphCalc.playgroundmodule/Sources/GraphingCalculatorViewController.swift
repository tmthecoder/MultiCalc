

import UIKit
import EquationParser

public class GraphingCalculatorViewController : UIViewController {
    let graphView = GraphView()
    let navigationBar = UINavigationBar()
    let graphExpressionField = UIButton()
    var loadingOverlay: UIView?
    
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
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initializeNavbarConstraints()
        initializeGraphInputConstraints()
        initializeGraphConstraints()
    }
    
    func initializeNavbar() {
        view.backgroundColor = .systemBackground
        // Create the actual item and add both right bar button items
        let navigationItem = UINavigationItem(title: "Graph")
        navigationBar.setItems([navigationItem], animated: false)
    }
    
    func initializeGraphField() {
        let symbolSize = UIImage.SymbolConfiguration(pointSize: 20)
        graphExpressionField.addTarget(self, action: #selector(onClicked), for: .touchUpInside)
        graphExpressionField.setImage(UIImage(systemName: "pencil", withConfiguration: symbolSize), for: .normal)
        graphExpressionField.semanticContentAttribute = .forceRightToLeft
        graphExpressionField.imageEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        resetGraphLabel()
    }
    
    func resetGraphLabel() {
        graphExpressionField.setTitle("Set Expression Here...", for: .normal)
        graphExpressionField.backgroundColor = .systemBackground
        graphExpressionField.setTitleColor(.placeholderText, for: .normal)
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
            graphExpressionField.leftAnchor.constraint(equalTo: view.leftAnchor),
            graphExpressionField.rightAnchor.constraint(equalTo: view.rightAnchor),
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
    
    @objc func onClicked() {
        let alert = UIAlertController(title: "Enter Expression", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { textField in
            let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissKeyboard))
            textField.placeholder = "Enter Here..."
            textField.inputView = EntryKeyboard(target: textField, showXVariable: true)
            textField.inputAccessoryView = EntryToolbar.shared.createToolbar(for: textField, dismissItem: doneBarButton)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.showSpinner()
            if let graphStr = alert.textFields?.first?.text {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.graphView.currentGraph = Graph(expression: try! ParseHelper.instance.parseExpression(from: graphStr, numeric: false))
                    DispatchQueue.main.sync {
                        self.graphView.redrawGraph()
                        self.removeSpinner()
                        self.graphExpressionField.setTitle(graphStr, for: .normal)
                        self.graphExpressionField.setTitleColor(self.traitCollection.userInterfaceStyle == .dark ? .white : .black, for: .normal)
                    }
                }
            }
        }))
        self.present(alert, animated: true)
    }
}
