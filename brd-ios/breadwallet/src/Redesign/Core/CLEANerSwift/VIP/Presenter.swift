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
        guard let error = actionResponse.error else { return }

        let config = AlertViewModel(title: nil, description: error.localizedDescription, buttons: ["click", "cancel"])
        viewController?.displayError(responseDisplay: .init(config: config))
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
        let model = AlertViewModel(title: actionResponse.alert?.title,
                                   description: actionResponse.alert?.description,
                                   image: actionResponse.alert?.image,
                                   buttons: actionResponse.alert?.buttons ?? [])
        
        let config = AlertConfiguration(titleConfiguration: Presets.Label.primary,
                                        descriptionConfiguration: Presets.Label.secondary,
                                        imageConfiguration: Presets.Image.primary,
                                        buttonConfigurations: [
                                            Presets.Button.primary,
                                            Presets.Button.secondary
                                        ])
        
        viewController?.displayAlert(responseDisplay: .init(alert: model, config: config))
    }
}
