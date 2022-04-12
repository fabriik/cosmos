//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCSignInRoutingLogic {
    var dataStore: KYCSignInDataStore? { get }
    
    func showKYCSignUpScene()
    func showKYCTutorialScene()
    func showKYCConfirmEmailScene()
    func showKYCForgotPasswordScene()
    func dismissFlow()
}

class KYCSignInRouter: NSObject, KYCSignInRoutingLogic {
    weak var viewController: KYCSignInViewController?
    var dataStore: KYCSignInDataStore?
    
    func showKYCSignUpScene() {
        let kycSignUpViewController = KYCSignUpViewController()
        viewController?.navigationController?.pushViewController(kycSignUpViewController, animated: true)
    }
    
    func showKYCTutorialScene() {
        let kycTutorialViewController = KYCTutorialViewController()
        kycTutorialViewController.navigationItem.setHidesBackButton(true, animated: true)
        viewController?.navigationController?.pushViewController(kycTutorialViewController, animated: true)
    }
    
    func showKYCConfirmEmailScene() {
        let kycSignUpViewController = KYCConfirmEmailViewController()
        var dataStore = kycSignUpViewController.router?.dataStore
        dataStore?.shouldResendCode = true
        viewController?.navigationController?.pushViewController(kycSignUpViewController, animated: true)
    }
    
    func showKYCForgotPasswordScene() {
        let kycForgotPasswordViewController = KYCForgotPasswordViewController()
        viewController?.navigationController?.pushViewController(kycForgotPasswordViewController, animated: true)
    }
    
    func dismissFlow() {
        viewController?.navigationController?.dismiss(animated: true)
    }
}
