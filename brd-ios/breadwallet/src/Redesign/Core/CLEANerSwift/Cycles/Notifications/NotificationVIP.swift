//
//  NotificationConfigurable.swift
//  
//
//  Created by Rok Cresnik on 01/12/2021.
//

import UIKit

protocol NotificationViewActions {}

protocol NotificationActionResponses {
    func presentNotification(actionResponse: NotificationModels.Notification.ActionResponse)
}

protocol NotificationResponseDisplays {
    func displayNotification(responseDisplay: NotificationModels.Notification.ResponseDisplay)
}
