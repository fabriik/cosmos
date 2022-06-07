//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class AccountVerificationInteractor: NSObject, Interactor, AccountVerificationViewActions {
    
    typealias Models = AccountVerificationModels

    var presenter: AccountVerificationPresenter?
    var dataStore: AccountVerificationStore?

    // MARK: - AccountVerificationViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: dataStore))
    }

    func startVerification(viewAction: AccountVerificationModels.Start.ViewAction) {
        presenter?.presentStartVerification(actionResponse: .init(level: Models.KYCLevel(rawValue: viewAction.level) ?? .one))
    }
    // MARK: - Aditional helpers
}
