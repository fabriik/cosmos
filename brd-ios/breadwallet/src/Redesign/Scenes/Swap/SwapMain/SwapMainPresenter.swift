//
//  SwapMainPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class SwapMainPresenter: NSObject, Presenter, SwapMainActionResponses {
    typealias Models = SwapMainModels
    
    weak var viewController: SwapMainViewController?
    
    // MARK: - SwapMainActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let sections: [Models.Sections] = [
            .swapCard,
            .confirm
        ]
        
        let sectionRows: [Models.Sections: [Any]] = [
            .swapCard: [
                // TODO: Populate
                MainSwapViewModel(fromFiatAmount: "", fromCryptoAmount: "", toFiatAmount: "", toCryptoAmount: "")
            ],
            .confirm: [
                // TODO: Localize
                ButtonViewModel(title: "Confirm")
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentSetAmount(actionResponse: SwapMainModels.Amounts.ActionResponse) {
        var fieldValidationIsAllowed = [String?: Bool]()
        
        fieldValidationIsAllowed["toFiatAmount"] = actionResponse.toFiatAmount == nil
        fieldValidationIsAllowed["toCryptoAmount"] = actionResponse.toCryptoAmount == nil
        fieldValidationIsAllowed["fromFiatAmount"] = actionResponse.fromFiatAmount == nil
        fieldValidationIsAllowed["fromCryptoAmount"] = actionResponse.fromCryptoAmount == nil
        
        let isValid = fieldValidationIsAllowed.values.contains(where: { $0 == false }) == true
        
        viewController?.displaySetAmount(responseDisplay: .init(fromFiatAmount: actionResponse.fromFiatAmount,
                                                                fromCryptoAmount: actionResponse.fromCryptoAmount,
                                                                toFiatAmount: actionResponse.toFiatAmount,
                                                                toCryptoAmount: actionResponse.toCryptoAmount,
                                                                shouldEnableConfirm: isValid))
    }
    
    // MARK: - Additional Helpers
    
}
