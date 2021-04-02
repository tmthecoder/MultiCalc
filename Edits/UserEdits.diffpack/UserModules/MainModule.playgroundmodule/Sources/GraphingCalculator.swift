
import Foundation
import UIKit
import CoreGraphics

public class GraphingCalculator : UIViewController {
    var graphView = GraphView()
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initializeGraph()
    }
    
    func initializeGraph() {
        view.backgroundColor = .systemBackground
        graphView.frame = view.bounds
        graphView.layer.setNeedsDisplay()
        view.addSubview(graphView)
        graphView.currentGraph = Graph(expression: "Hi")
    }
    
}
