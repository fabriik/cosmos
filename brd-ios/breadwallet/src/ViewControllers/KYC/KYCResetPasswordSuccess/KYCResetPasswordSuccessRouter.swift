// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCResetPasswordSuccessRoutingLogic {
    var dataStore: KYCResetPasswordSuccessDataStore? { get }
    
    func dismissFlow()
}

class KYCResetPasswordSuccessRouter: NSObject, KYCResetPasswordSuccessRoutingLogic {
    weak var viewController: KYCResetPasswordSuccessViewController?
    var dataStore: KYCResetPasswordSuccessDataStore?
    
    func dismissFlow() {
        viewController?.navigationController?.popToRootViewController(animated: true)
    }
}
