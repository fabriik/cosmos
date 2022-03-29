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
        // TODO: Move colors to constants
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.kycCompletelyWhite]
            appearance.backgroundColor = UIColor(red: 38.0/255.0, green: 21.0/255.0, blue: 56.0/255.0, alpha: 1.0)
            appearance.shadowColor = nil
            
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.standardAppearance = appearance
            navigationBar.compactAppearance = appearance
        }
        
        navigationBar.tintColor = .kycCompletelyWhite
        navigationBar.barTintColor = .kycCompletelyWhite
        navigationBar.shadowImage = UIImage()
        navigationBar.prefersLargeTitles = false
        
        view.backgroundColor = .clear
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = SimpleBackBarButtonItem(title: "        ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
}

class SimpleBackBarButtonItem: UIBarButtonItem {
    @available(iOS 14.0, *)
    override var menu: UIMenu? {
        get {
            return super.menu
        }
        set {}
    }
}
