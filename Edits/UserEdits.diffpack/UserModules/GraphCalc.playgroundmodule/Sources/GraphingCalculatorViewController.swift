import UIKit
import EquationParser

/// The main view controller for the Graphing Calculator
public class GraphingCalculatorViewController : UIViewController {
    
    /// The underlying graph view
    let graphView = GraphView()
    /// The top navigation bar
    let navigationBar = UINavigationBar()
    /// The textfield to input and change the expression
    let graphExpressionField = UITextField()
    /// The loading overlay view (to display for long-running graph operations)
    var loadingOverlay: UIView?
    /// A variable to determine whether the keyboard is displayed
    var keyboardActive = false
    
    /// Initialize all of the views with their subviews when the view loads
    /// Also adds all the initialized views to the main view
    public override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        // Add the subviews
        view.addSubview(navigationBar)
        view.insertSubview(graphExpressionField, belowSubview: navigationBar)
        view.insertSubview(graphView, belowSubview: graphExpressionField)
        // Initialize UI objects
        initializeNavbar()
        initializeGraphField()
    }
    
    /// Add the observers for the keyboard shown and hidden event to update the keyboardActive variable
    public override func viewDidAppear(_ animated: Bool) {
        //The keyboard will show notification
        NotificationCenter.default.addObserver(
            self,selector: #selector(self.keyboardDidShow(_:)),name: UIResponder.keyboardWillShowNotification, object: nil)
        // The keyboard will hide notification
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.keyboardDidHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// Remove the observer fro, the keyboard shown and hidden events as the view is no longer visible
    public override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillShowNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
        graphView.removePointView()
    }
    
    /// Handle any view resizing once the bounds are reset or the view is brought back into visibility
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Only resize if the keyboard is not active
        if !keyboardActive {
            // Create all views
            initializeNavbarConstraints()
            initializeGraphInputConstraints()
            initializeGraphConstraints()
            graphView.setNeedsDisplay()
        }
    }
    
    /// A method to initialize the Navigation bar and set its items
    func initializeNavbar() {
        view.backgroundColor = .systemBackground
        // Create the actual item and add both right bar button items
        let navigationItem = UINavigationItem(title: "Graph")
        navigationBar.setItems([navigationItem], animated: false)
    }
    
    /// A method to initialize the textfield for the graph
    func initializeGraphField() {
        // Set the alignment and background
        graphExpressionField.textAlignment = .center
        graphExpressionField.backgroundColor = .systemBackground
        // Add a button to click when a user is finished setting an expression
        let finishButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 60))
        let symbolSize = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "checkmark", withConfiguration: symbolSize)
        finishButton.setImage(image, for: .normal)
        finishButton.addTarget(self, action: #selector(graphExpression), for: .touchUpInside)
        // Make sure the check button is added and shows
        graphExpressionField.rightView = finishButton
        graphExpressionField.rightViewMode = .always
        graphExpressionField.placeholder = "Enter expression Here..."
        // Make sure the field uses our custom input views
        let dismissItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        graphExpressionField.inputView = EntryKeyboard(target: graphExpressionField, showXVariable: true)
        graphExpressionField.inputAccessoryView = EntryToolbar.shared.createToolbar(for: graphExpressionField, dismissItem: dismissItem)
    }
    
    /// A method to update the currently shown graph
    /// Sets the graph to one parsed from the string in the expression box
    func updateGraph() {
        if let graphStr = graphExpressionField.text {
            self.showLoadingIndicator()
            DispatchQueue.global(qos: .userInitiated).async {
                // Check if the expression can be parsed
                do {
                    let expression = try ParseHelper.instance.parseExpression(from: graphStr, numeric: false)
                    // Set the graph and reload the display
                    self.graphView.currentGraph = Graph(expression: expression)
                    DispatchQueue.main.sync {
                        self.removeLoadingIndicator()
                        self.graphView.setNeedsDisplay()
                    }
                } catch {
                    // Show the error alert
                    DispatchQueue.main.sync {
                        self.removeLoadingIndicator()
                        self.showErrorAlert()
                    }
                }
            }
        }
    }
    
    /// A methdo to show an akert when the equation parse process errors out
    func showErrorAlert() {
        // Create the alert with the message and title
        let alert = UIAlertController(
            title: "Equation Error", message: "There was an error with your equation. Please enter a fixed equation", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        // Show it
        self.present(alert, animated: true, completion: nil)
    }
    
    /// A methdo to initialuze all of the constraints for the top navigation bar
    func initializeNavbarConstraints() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    /// A method to initialize the constraints for the graph input text field
    func initializeGraphInputConstraints() {
        graphExpressionField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            graphExpressionField.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            graphExpressionField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            graphExpressionField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            graphExpressionField.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    /// A method to initialize the constraints for the actual graph view object
    func initializeGraphConstraints() {
//          guard let tabBar = tabBarController?.tabBar else {return}
        graphView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            graphView.topAnchor.constraint(equalTo: graphExpressionField.bottomAnchor),
            graphView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            graphView.rightAnchor.constraint(equalTo: view.rightAnchor),
            graphView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }
    
    /// A method to show the overlay and onscreen loading indicator
    /// Disables extra user interaction and overloading of computation
    func showLoadingIndicator() {
        let spinnerView = UIView(frame: view.bounds)
        spinnerView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        let ai = UIActivityIndicatorView.init(style: .medium)
        ai.startAnimating()
        ai.center = spinnerView.center
        spinnerView.addSubview(ai)
        view.addSubview(spinnerView)
        loadingOverlay = spinnerView
    }
    
    /// A method to remove the loading indicator
    func removeLoadingIndicator() {
        self.loadingOverlay?.removeFromSuperview()
        self.loadingOverlay = nil
    }
    
    /// A method to call to dismiss the shown keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// A method to call once a keyboard was shown
    @objc func keyboardDidShow(_ notification: Notification) {
        keyboardActive = true
    }
    
    /// A method to call once the keyboard is hidden
    @objc func keyboardDidHide(_ notification: Notification) {
        keyboardActive = false
    }
    
    /// A method to call to update the graph on screen
    @objc func graphExpression() {
        updateGraph()
    }
}
