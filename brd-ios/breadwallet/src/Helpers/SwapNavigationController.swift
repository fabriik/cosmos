// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

class SwapNavigationController: UINavigationController, UINavigationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        setup()
    }
    
    private func setup() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: Theme.primaryText]
            appearance.backgroundColor = Theme.primaryBackground
            appearance.shadowColor = nil
            
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.standardAppearance = appearance
            navigationBar.compactAppearance = appearance
        }
        
        navigationBar.tintColor = .almostBlack
        navigationBar.barTintColor = .almostBlack
        navigationBar.shadowImage = UIImage()
        navigationBar.prefersLargeTitles = false
        
        view.backgroundColor = .clear
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = SimpleBackBarButtonItem(title: "        ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
}
