//
// Created by Equaleyes Solutions Ltd
//

import UIKit

extension Scenes {
    static let AccountVerification = AccountVerificationViewController.self
}

protocol AccountVerificationViewActions: BaseViewActions, FetchViewActions {
    func startVerification(viewAction: AccountVerificationModels.Start.ViewAction)
}

protocol AccountVerificationActionResponses: BaseActionResponses, FetchActionResponses {
    func presentStartVerification(actionResponse: AccountVerificationModels.Start.ActionResponse)
}

protocol AccountVerificationResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayStartVerification(responseDisplay: AccountVerificationModels.Start.ResponseDisplay)
}

protocol AccountVerificationDataStore: BaseDataStore, FetchDataStore {
    var verificationStatus: VerificationStatus? { get set }
    var profile: Profile? { get set }
}

protocol AccountVerificationDataPassing {
    var dataStore: AccountVerificationDataStore? { get }
}

protocol AccountVerificationRoutes: CoordinatableRoutes {
}
