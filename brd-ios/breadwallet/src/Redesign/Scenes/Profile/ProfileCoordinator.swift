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
        guard let view = navigationController.view else { return }
        
        let blurView = UIVisualEffectView()
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
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
        popup.transform = .init(translationX: 0, y: UIScreen.main.bounds.height)
        popup.layoutIfNeeded()
        
        popup.configure(with: Presets.Popup.normal)
        popup.setup(with: model)
        
        popup.buttonCallbacks = callbacks
        popup.closeCallback = { [weak self] in
            self?.hidePopup()
        }
        
        UIView.animate(withDuration: Presets.Animation.duration,
                       delay: 0,
                       options: .transitionCrossDissolve) {
            blurView.effect = UIBlurEffect(style: .regular)
            popup.alpha = 1
            popup.transform = .identity
        }
    }
    
    // MARK: - Additional Helpers
    @objc func hidePopup() {
        guard let view = navigationController.view,
              let popup = view.subviews.first(where: { $0 is FEPopupView }) else { return }
        
        let blur = view.subviews.first(where: { $0 is UIVisualEffectView }) as? UIVisualEffectView
        
        UIView.animate(withDuration: Presets.Animation.duration,
                       delay: 0,
                       options: .transitionCrossDissolve) {
            blur?.effect = nil
            popup.alpha = 0
            popup.transform = .init(translationX: 0, y: UIScreen.main.bounds.height)
        } completion: { _ in
            popup.removeFromSuperview()
            blur?.removeFromSuperview()
        }
    }
}
