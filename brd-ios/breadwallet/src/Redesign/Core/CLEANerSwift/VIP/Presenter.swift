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

        let model = InfoViewModel(headerTitle: .text("Error"), description: .text(error.localizedDescription), tapToDismiss: true)
        
        // TODO: create Error preset
        let config = Presets.InfoView.primary

        viewController?.displayError(responseDisplay: .init(model: model, config: config))
    }

    func presentNotification(actionResponse: NotificationModels.Notification.ActionResponse) {
        let model = InfoViewModel(description: .text(actionResponse.text), tapToDismiss: actionResponse.autoDimissisable)
        viewController?.displayNotification(responseDisplay: .init(model: model))
    }

    func presentAlert(actionResponse: AlertModels.Alerts.ActionResponse) {
        let model = AlertViewModel(title: actionResponse.alert?.title,
                                   description: actionResponse.alert?.description,
                                   image: actionResponse.alert?.image,
                                   buttons: actionResponse.alert?.buttons ?? [])
        
        viewController?.displayAlert(responseDisplay: .init(model: model, config: Presets.Alert.one))
    }
}
