// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCResetPasswordRoutingLogic {
    var dataStore: KYCResetPasswordDataStore? { get }
    
    func showKResetPasswordSuccessScene()
}

class KYCResetPasswordRouter: NSObject, KYCResetPasswordRoutingLogic {
    weak var viewController: KYCResetPasswordViewController?
    var dataStore: KYCResetPasswordDataStore?
    
    func showKResetPasswordSuccessScene() {
        let kycResetPasswordSuccessViewController = KYCResetPasswordSuccessViewController()
        kycResetPasswordSuccessViewController.navigationItem.setHidesBackButton(true, animated: false)
        viewController?.navigationController?.pushViewController(kycResetPasswordSuccessViewController, animated: true)
    }
}
