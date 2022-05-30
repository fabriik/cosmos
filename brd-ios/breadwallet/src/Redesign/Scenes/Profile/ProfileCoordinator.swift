//
//  ProfileCoordinator.swift
//  breadwallet
//
//  Created by Rok on 26/05/2022.
//
//

import UIKit

class ProfileCoordinator: BaseCoordinator, ProfileRoutes {
    // MARK: - ProfileRoutes
    
    func showAvatarSelection() {
        // TODO: navigate on
        showUnderConstruction("avatar selection")
    }
    
    func showSecuirtySettings() {
        
    }
    
    func showPreferences() {
        
    }
    
    func showExport() {
        
    }
    
    func showUnderConstruction(_ feat: String) {
        // TODO: navigate on
        showPopup(with: .init(title: .text("Under construction"),
                              body: "The \(feat.uppercased()) functionality is being developed for You by the awesome Fabriik team. Stay tuned!"))
    }
    // MARK: - Aditional helpers
}

extension BaseCoordinator {
    func showPopup(with model: PopupViewModel, callbacks: [(() -> Void)] = []) {
        guard let view = navigationController.topViewController?.view else { return }
        
        let blur = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        
        view.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let popup = FEPopupView()
        view.addSubview(popup)
        popup.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(view.snp.leadingMargin)
            make.trailing.greaterThanOrEqualTo(view.snp.trailingMargin)
        }
        popup.alpha = 0
        popup.layoutIfNeeded()
        popup.configure(with: Presets.Popup.normal)
        popup.setup(with: model)
        popup.buttonCallbacks = callbacks
        
        popup.closeCallback = { [weak self] in
            self?.hidePopup()
        }
        
        UIView.animate(withDuration: Presets.Animation.duration) {
            popup.alpha = 1
            blurView.alpha = 1
        }
    }
    
    // MARK: - Additional Helpers
    @objc func hidePopup() {
        guard let view = navigationController.topViewController?.view,
              let popup = view.subviews.first(where: { $0 is FEPopupView })
        else { return }
        let blur = view.subviews.first(where: { $0 is UIVisualEffectView })
        
        UIView.animate(withDuration: Presets.Animation.duration) {
            popup.alpha = 0
            blur?.alpha = 0
        } completion: { _ in
            popup.removeFromSuperview()
            blur?.removeFromSuperview()
        }
    }
}
