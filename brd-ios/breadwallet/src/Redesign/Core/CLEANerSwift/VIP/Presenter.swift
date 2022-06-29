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
    func presentError(actionResponse: MessageModels.Errors.ActionResponse) {
        guard let error = actionResponse.error as? NetworkingError else { return }

        let responseDisplay: MessageModels.ResponseDisplays
        if let error = error as? SessioExpiredError {
            responseDisplay = .init(error: error)
        } else {
            // TODO: Investigate localized errors
            let model = InfoViewModel(headerTitle: .text("Error"), description: .text(error.errorMessage))
            
            // TODO: create Error preset
            let config = Presets.InfoView.primary
            responseDisplay = .init(model: model, config: config)
        }
    
        viewController?.displayMessage(responseDisplay: responseDisplay)
    }
    
    func presentNotification(actionResponse: MessageModels.Notification.ActionResponse) {
        let model = InfoViewModel(title: actionResponse.title != nil ?.text(actionResponse.title) : nil,
                                  description: actionResponse.body != nil ?.text(actionResponse.body) : nil,
                                  dismissType: actionResponse.dissmiss)
        
        // TODO: create notification preset
        let config = Presets.InfoView.primary
        
        viewController?.displayMessage(responseDisplay: .init(model: model, config: config))
    }
    
    func presentAlert(actionResponse: MessageModels.Alert.ActionResponse) {
        let model = InfoViewModel(title: .text(actionResponse.title),
                                  description: .text(actionResponse.body))
        
        // TODO: create alert preset
        let config = Presets.InfoView.primary
        viewController?.displayMessage(responseDisplay: .init(model: model, config: config))
    }
}
