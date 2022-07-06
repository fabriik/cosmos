//
//  SwapPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class SwapPresenter: NSObject, Presenter, SwapActionResponses {
    typealias Models = SwapModels
    
    weak var viewController: SwapViewController?
    
    // MARK: - SwapActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let sections: [Models.Sections] = [
            .swapCard,
            .confirm
        ]
        
        let sectionRows: [Models.Sections: [Any]] = [
            .swapCard: [
                // TODO: Populate
                MainSwapViewModel(fromFiatAmount: 0, fromFiatAmountString: "",
                                  fromCryptoAmount: 0, fromCryptoAmountString: "",
                                  toFiatAmount: 0, toFiatAmountString: "",
                                  toCryptoAmount: 0, toCryptoAmountString: "")
            ],
            .confirm: [
                // TODO: Localize
                ButtonViewModel(title: "Confirm")
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentSetAmount(actionResponse: SwapModels.Amounts.ActionResponse) {
        var fieldValidationIsAllowed = [String?: Bool]()
        
        fieldValidationIsAllowed["toFiatAmount"] = actionResponse.toFiatAmount?.doubleValue ?? 0 > 0
        fieldValidationIsAllowed["toCryptoAmount"] = actionResponse.toCryptoAmount?.doubleValue ?? 0 > 0
        fieldValidationIsAllowed["fromFiatAmount"] = actionResponse.fromFiatAmount?.doubleValue ?? 0 > 0
        fieldValidationIsAllowed["fromCryptoAmount"] = actionResponse.fromCryptoAmount?.doubleValue ?? 0 > 0
        
        let isValid = fieldValidationIsAllowed.values.contains(where: { $0 == true }) == true
        
        viewController?.displaySetAmount(responseDisplay: .init(amounts:
                .init(fromFiatAmount: actionResponse.fromFiatAmount ?? 0,
                      fromFiatAmountString: currencyInputFormatting(numberString: actionResponse.fromFiatAmount?.stringValue),
                      fromCryptoAmount: actionResponse.fromCryptoAmount ?? 0,
                      fromCryptoAmountString: currencyInputFormatting(numberString: actionResponse.fromCryptoAmount?.stringValue),
                      toFiatAmount: actionResponse.toFiatAmount ?? 0,
                      toFiatAmountString: currencyInputFormatting(numberString: actionResponse.toFiatAmount?.stringValue),
                      toCryptoAmount: actionResponse.toCryptoAmount ?? 0,
                      toCryptoAmountString: currencyInputFormatting(numberString: actionResponse.toCryptoAmount?.stringValue)),
                                                                shouldEnableConfirm: isValid))
    }
    
    // MARK: - Additional Helpers
    
    func currencyInputFormatting(numberString: String?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumIntegerDigits = 10
        
        let regex = try? NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        let numberString = regex?.stringByReplacingMatches(in: numberString ?? "",
                                                           options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                                           range: NSRange(location: 0,
                                                                          length: numberString?.count ?? 0),
                                                           withTemplate: "") ?? ""
        
        let double = (numberString as NSString).doubleValue
        let number = NSNumber(value: (double / 100))
        
        return formatter.string(from: number) ?? ""
    }
}
