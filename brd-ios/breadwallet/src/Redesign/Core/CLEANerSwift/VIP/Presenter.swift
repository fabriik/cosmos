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

        let model = AlertViewModel(title: nil, description: error.localizedDescription, buttons: ["click", "cancel"])
        
        // TODO: set proper configs
        let config = AlertConfiguration(titleConfiguration: .init(),
                                        descriptionConfiguration: .init(),
                                        imageConfiguration: Presets.Image.primary,
                                        buttonConfigurations: [
                                            Presets.Button.primary,
                                            Presets.Button.secondary
                                        ])

        viewController?.displayError(responseDisplay: .init(model: model, config: config))
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
        
        viewController?.displayAlert(responseDisplay: .init(model: model, config: Presets.Alert.one))
    }
}
