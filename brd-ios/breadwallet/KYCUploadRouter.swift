// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol KYCUploadRoutingLogic {
    var dataStore: KYCUploadDataStore? { get }
    
    func showKYCCompleteScene()
}

class KYCUploadRouter: NSObject, KYCUploadRoutingLogic {
    weak var viewController: KYCUploadViewController?
    var dataStore: KYCUploadDataStore?
    
    func showKYCCompleteScene() {
        let kycCompleteViewController = KYCCompleteViewController()
        kycCompleteViewController.navigationItem.setHidesBackButton(true, animated: false)
        viewController?.navigationController?.pushViewController(kycCompleteViewController, animated: true)
    }
}
