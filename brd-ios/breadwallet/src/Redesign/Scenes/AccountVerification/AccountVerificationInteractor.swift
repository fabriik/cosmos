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
        presenter?.presentData(actionResponse: .init(item: Models.Item(title: "Under construction", image: "earth")))
    }

    // MARK: - Aditional helpers
}
