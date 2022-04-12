// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCForgotPasswordRoutingLogic {
    var dataStore: KYCForgotPasswordDataStore? { get }
    
    func showKYCResetPasswordScene()
}

class KYCForgotPasswordRouter: NSObject, KYCForgotPasswordRoutingLogic {
    weak var viewController: KYCForgotPasswordViewController?
    var dataStore: KYCForgotPasswordDataStore?
    
    func showKYCResetPasswordScene() {
        let kycResetPasswordViewController = KYCResetPasswordViewController()
        viewController?.navigationController?.pushViewController(kycResetPasswordViewController, animated: true)
    }
}
