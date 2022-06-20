//
//  UIViewController+BRWAdditions.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-21.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import UIKit

extension UIViewController {
    enum NavBarButtonSide {
        case left
        case right
    }
    
    func addChildViewController(_ viewController: UIViewController, layout: () -> Void) {
        addChild(viewController)
        view.addSubview(viewController.view)
        layout()
        viewController.didMove(toParent: self)
    }

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    func setLastBarButtonItem(from navigationController: UINavigationController, to side: NavBarButtonSide) {
        switch side {
        case .left:
            navigationItem.leftBarButtonItem = navigationController.children.last?.navigationItem.leftBarButtonItem
        case .right:
            navigationItem.rightBarButtonItem = navigationController.children.last?.navigationItem.rightBarButtonItem
        }
    }
        
    func addCloseNavigationItem(tintColor: UIColor? = nil, side: NavBarButtonSide = .left) {
        let close = UIButton.close
        close.tap = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        if let color = tintColor {
            close.tintColor = color
        } else {
            close.tintColor = .navigationTint
        }
        switch side {
        case .left:
            navigationItem.leftBarButtonItems = [UIBarButtonItem.negativePadding, UIBarButtonItem(customView: close)]
        case .right:
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: close), UIBarButtonItem.negativePadding]
        }
    }

    var safeTopAnchor: NSLayoutYAxisAnchor {
        return view.safeAreaLayoutGuide.topAnchor
    }

    var safeBottomAnchor: NSLayoutYAxisAnchor {
        return view.safeAreaLayoutGuide.bottomAnchor
    }
    
    func setAsNonDismissableModal() {
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        } else {
            modalPresentationStyle = .overFullScreen
        }
    }
}
