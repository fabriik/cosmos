//
// Created by Equaleyes Solutions Ltd
//

import UIKit

extension Scenes {
    static let VerifyAccount = VerifyAccountViewController.self
}

protocol VerifyAccountViewActions: BaseViewActions, FetchViewActions {
}

protocol VerifyAccountActionResponses: BaseActionResponses, FetchActionResponses {
}

protocol VerifyAccountResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
}

protocol VerifyAccountDataStore: BaseDataStore, FetchDataStore {
}

protocol VerifyAccountDataPassing {
    var dataStore: VerifyAccountDataStore? { get }
}

protocol VerifyAccountRoutes: CoordinatableRoutes {
    func showVerifications()
}
