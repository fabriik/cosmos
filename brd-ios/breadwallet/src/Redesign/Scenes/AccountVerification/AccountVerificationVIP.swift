//
// Created by Equaleyes Solutions Ltd
//

import UIKit

extension Scenes {
    static let AccountVerification = AccountVerificationViewController.self
}

protocol AccountVerificationViewActions: BaseViewActions, FetchViewActions {
}

protocol AccountVerificationActionResponses: BaseActionResponses, FetchActionResponses {
}

protocol AccountVerificationResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
}

protocol AccountVerificationDataStore: BaseDataStore, FetchDataStore {
}

protocol AccountVerificationDataPassing {
    var dataStore: AccountVerificationDataStore? { get }
}

protocol AccountVerificationRoutes: CoordinatableRoutes {
}
