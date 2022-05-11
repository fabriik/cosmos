//
//  Presenter.swift
//  MagicFactory
//
//  Created by Rok Cresnik on 20/08/2021.
//

import UIKit

protocol Presenter: NSObject, BaseActionResponses {
    associatedtype ResponseDisplays: BaseResponseDisplays
    var viewController: ResponseDisplays? { get set }
}

extension Presenter {
    func presentError(actionResponse: ErrorModels.Errors.ActionResponse) {
//        guard let error = actionResponse.error else { return }
//
//        let config = Any(title: nil,
//                                        description: error.localizedDescription,
//                                        image: nil,
//                                        error: error)
//
//        viewController?.displayError(responseDisplay: .init(config: config))
    }

    func presentNotification(actionResponse: NotificationModels.Notification.ActionResponse) {
        let config = NotificationConfiguration(text: actionResponse.text,
                                               autoDismissable: actionResponse.autoDimissisable) { notificationView in
            // TODO: animation?
            notificationView.removeFromSuperview()
        }

        viewController?.displayNotification(responseDisplay: .init(config: config))
    }

    func presentAlert(actionResponse: AlertModels.Alerts.ActionResponse) {
//        let alert = actionResponse.alert
//        let config = Any(title: alert?.title,
//                                        description: alert?.description,
//                                        image: alert?.image,
//                                        mainButtonConfiguration: alert?.primaryConfiguration,
//                                        subButtonConfiguration: alert?.secondaryConfiguration,
//                                        tertiaryConfiguration: alert?.tertiaryConfigraution)
//
//        viewController?.displayAlert(responseDisplay: .init(config: nil))
    }
}
