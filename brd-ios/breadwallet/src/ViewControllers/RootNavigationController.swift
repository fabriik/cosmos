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
        guard let vc = topViewController else { return .default }
        return vc.preferredStatusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        setNormalNavigationBar()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is AccountViewController ||
            viewController is HomeScreenViewController ||
            viewController is KYCCameraViewController {
            setNormalNavigationBar(normalBackgroundColor: .clear, scrollBackgroundColor: .clear, tintColor: LightColors.Contrast.two)
        } else {
            setNormalNavigationBar()
        }
        
        let item = SimpleBackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
    
    func setNormalNavigationBar(normalBackgroundColor: UIColor = LightColors.Contrast.two,
                                scrollBackgroundColor: UIColor = .clear,
                                tintColor: UIColor = LightColors.Icons.one) {
        if #available(iOS 13.0, *) {
            let normalAppearance = UINavigationBarAppearance()
            normalAppearance.configureWithOpaqueBackground()
            normalAppearance.backgroundColor = normalBackgroundColor
            normalAppearance.shadowColor = nil
            navigationBar.standardAppearance = normalAppearance
            navigationBar.compactAppearance = normalAppearance
            
            let scrollAppearance = UINavigationBarAppearance()
            scrollAppearance.configureWithTransparentBackground()
            scrollAppearance.backgroundColor = scrollBackgroundColor
            scrollAppearance.shadowColor = nil
            navigationBar.scrollEdgeAppearance = scrollAppearance
        } else {
            if normalBackgroundColor == .clear {
                navigationBar.setBackgroundImage(UIImage(), for: .default)
            }
            
            navigationBar.shadowImage = UIImage()
            navigationBar.barTintColor = normalBackgroundColor
        }
        
        navigationBar.tintColor = tintColor
        navigationBar.prefersLargeTitles = false
        
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: Fonts.Title.seven
        ]
        
        view.backgroundColor = LightColors.Contrast.two
    }
}
