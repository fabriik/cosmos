//
//  RootNavigationController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-12-05.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

class RootNavigationController: UINavigationController, UINavigationControllerDelegate {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        delegate = self
        
        if #available(iOS 13.0, *) {
            let normalAppearance = UINavigationBarAppearance()
            normalAppearance.configureWithOpaqueBackground()
            normalAppearance.backgroundColor = Theme.primaryBackground
            normalAppearance.shadowColor = nil
            navigationBar.standardAppearance = normalAppearance
            navigationBar.compactAppearance = normalAppearance
            
            let scrollAppearance = UINavigationBarAppearance()
            scrollAppearance.configureWithOpaqueBackground()
            scrollAppearance.backgroundColor = .clear
            scrollAppearance.shadowColor = nil
            navigationBar.scrollEdgeAppearance = scrollAppearance
        }
        
        navigationBar.tintColor = LightColors.Icons.one
        navigationBar.barTintColor = Theme.primaryBackground
        navigationBar.shadowImage = UIImage()
        navigationBar.prefersLargeTitles = false
        
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.almostBlack ,
            NSAttributedString.Key.font: UIFont.header
        ]
        
        view.backgroundColor = Theme.primaryBackground
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is HomeScreenViewController {
            navigationBar.tintColor = .navigationTint
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is AccountViewController {
            navigationBar.tintColor = .white
        }
        
        let item = SimpleBackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
