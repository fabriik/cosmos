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
    
    override func start() {
        open(scene: Scenes.Profile)
    }
    
    func showVerificationScreen(for profile: Profile?) {
        openModally(coordinator: KYCCoordinator.self, scene: Scenes.AccountVerification) { vc in
            vc?.dataStore?.profile = profile
            vc?.prepareData()
        }
        
    }
    
    func showAvatarSelection() {
        // TODO: navigate on
        showUnderConstruction("avatar selection")
    }
    
    func showSecuirtySettings() {
        modalPresenter?.presentSecuritySettings()
    }
    
    func showPreferences() {
        modalPresenter?.presentPreferences()
    }
    
    func showExport() {}

    // MARK: - Aditional helpers
    override func goBack() {
        navigationController.popViewController(animated: true)
    }
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
