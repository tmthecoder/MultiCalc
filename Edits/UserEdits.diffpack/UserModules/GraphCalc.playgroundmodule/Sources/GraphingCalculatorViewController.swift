

import UIKit

public class GraphingCalculatorViewController : UIViewController {
    var graphView = GraphView()
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initializeGraph()
    }
    
    func initializeGraph() {
        view.backgroundColor = .systemBackground
        let tabBar = tabBarController!.tabBar
        view.addSubview(graphView)
        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        graphView.bottomAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        graphView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        graphView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        graphView.currentGraph = Graph(expression: "Hi")
    }
    
}
