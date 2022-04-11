//
//  KYCResetPasswordSuccessRouter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/04/2022.
//  Copyright (c) 2022 Fabriik Exchange, LLC. All rights reserved.
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
