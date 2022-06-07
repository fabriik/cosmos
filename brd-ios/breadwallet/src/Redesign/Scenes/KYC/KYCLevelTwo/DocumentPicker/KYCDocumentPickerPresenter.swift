//
//  KYCDocumentPickerPresenter.swift
//  breadwallet
//
//  Created by Rok on 07/06/2022.
//
//

import UIKit

final class KYCDocumentPickerPresenter: NSObject, Presenter, KYCDocumentPickerActionResponses {
    typealias Models = KYCDocumentPickerModels

    weak var viewController: KYCDocumentPickerViewController?

    // MARK: - KYCDocumentPickerActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        
    }

    // MARK: - Additional Helpers

}
