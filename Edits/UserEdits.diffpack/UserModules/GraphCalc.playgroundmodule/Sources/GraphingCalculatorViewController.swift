

import UIKit

public class GraphingCalculatorViewController : UIViewController {
    let graphView = GraphView()
    let navigationBar = UINavigationBar()
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initializeNavbar()
        initializeGraph()
        graphView.currentGraph = Graph(expression: "HI")
    }
    
    func initializeNavbar() {
        view.backgroundColor = .systemBackground
        // Create the actual item and add both right bar button items
        let navigationItem = UINavigationItem(title: "Graph")
        navigationBar.setItems([navigationItem], animated: false)
        if navigationBar.superview == nil {
            view.addSubview(navigationBar)
        }
        initializeNavbarConstraints()
    }
    
    func initializeGraph() {
        view.backgroundColor = .systemBackground
        if graphView.superview == nil {
            view.insertSubview(graphView, belowSubview: navigationBar)
        }
        initializeGraphConstraints()
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
    
    func initializeGraphConstraints() {
        guard let tabBar = tabBarController?.tabBar else {return}
        graphView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            graphView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            graphView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            graphView.rightAnchor.constraint(equalTo: view.rightAnchor),
            graphView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }
}
