//
// Created by Equaleyes Solutions Ltd
//

import UIKit

class VerifyAccountInteractor: NSObject, Interactor, VerifyAccountViewActions {
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: nil))
    }
    
    typealias Models = VerifyAccountModels

    var presenter: VerifyAccountPresenter?
    var dataStore: VerifyAccountStore?

    // MARK: - VerifyAccountViewActions

    // MARK: - Aditional helpers
}
