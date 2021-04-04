

import UIKit

public class GraphingCalculatorViewController : UIViewController {
    var graphView = GraphView()
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initializeGraph()
    }
    
    func initializeGraph() {
        view.backgroundColor = .systemBackground
        if graphView.superview == nil {
            view.addSubview(graphView)
        }
        initializeGraphConstraints()
    }
    func initializeGraphConstraints() {
        guard let tabBar = tabBarController?.tabBar else {return}
        graphView.translatesAutoresizingMaskIntoConstraints = false
        graphView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        graphView.bottomAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        graphView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        graphView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    }
}
