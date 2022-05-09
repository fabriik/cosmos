//
//  BaseVIP.swift
//  MagicFactory
//
//  Created by Rok Cresnik on 20/08/2021.
//

import UIKit

protocol BaseViewActions: AlertViewActions,
                                 ErrorViewActions,
                                 NotificationViewActions {
}

protocol BaseActionResponses: AlertActionResponses,
                                     ErrorActionResponses,
                                     NotificationActionResponses {
}

protocol BaseResponseDisplays: AlertResponseDisplays,
                                      ErrorResponseDisplays,
                                      NotificationResponseDisplays {
}

protocol BaseDataStore {}

protocol BaseDataPassing {
    associatedtype Store: BaseDataStore
    var dataStore: Store? { get }
}

protocol CoordinatableRoutes: NSObject,
                                     AlertDisplayable,
                                     NotificationDisplayable {
    func goBack()
}

protocol AlertDisplayable {
    func showAlertView(with config: AlertConfiguration)
}
