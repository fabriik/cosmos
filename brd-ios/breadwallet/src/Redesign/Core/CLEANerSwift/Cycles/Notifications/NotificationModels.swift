//
//  NotificationModel.swift
//  MagicFactory
//
//  Created by Rok Cresnik on 20/08/2021.
//

import UIKit

enum NotificationModels {
    enum Notification {
        struct ViewAction {
            init() {}
        }
        
        struct ActionResponse {
            var text: String
            var autoDimissisable: Bool
        }
        
        struct ResponseDisplay {
            var model: InfoViewModel?
            var config: InfoViewConfiguration?
        }
    }
}

protocol NotificationDisplayable {
    func showNotification(with model: InfoViewModel?, configuration: InfoViewConfiguration?)
    func hideNotification(_ view: UIView)
}
