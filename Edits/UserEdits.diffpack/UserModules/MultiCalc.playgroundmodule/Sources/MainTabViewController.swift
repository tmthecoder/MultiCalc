import UIKit
import DrawCalc
import GraphCalc

/// The main Tab Bar Controller for the application
/// Contains the Draw and Graph calculator view controllers as tabs
class MainTabController : UITabBarController, UITabBarControllerDelegate {
    
    /// Set the delegate for this TabBarController
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    /// Create the item for both the Draw and Graph calculator View Controllers
    /// Set their respective images and add them to the tab bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let drawController = createTabBarItem(title: "Draw", image: UIImage(systemName: "hand.draw")!, selectedImage: UIImage(systemName: "hand.draw.fill")!, controller: DrawCalculatorViewController())
        let openImage = UIImage(named: "graph")!
        let filledImage = UIImage(named: "graph_fill")!
        let graphController = createTabBarItem(title: "Graph", image: openImage, selectedImage: filledImage, controller: GraphingCalculatorViewController())
        let controllers = [drawController, graphController]
        self.viewControllers = controllers
    }
    
    /// A generic method to assist with the creation of a Tab Bar Item
    /// Simplifies the dulplicate code calls for setting an image and creating the item
    func createTabBarItem(title: String, image: UIImage, selectedImage: UIImage, controller: UIViewController) -> UIViewController {
        let item = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        controller.tabBarItem = item
        return controller
    }
    
    /// An override method for the TabBarControllerDelegate to allow tab selection
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true;
    }
}
