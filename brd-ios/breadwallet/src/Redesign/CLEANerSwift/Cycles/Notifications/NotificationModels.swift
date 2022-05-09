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

            init(text: String, autoDimissisable: Bool = true) {
                self.text = text
                self.autoDimissisable = autoDimissisable
            }
        }
        
        struct ResponseDisplay {
            var config: NotificationConfiguration

            init(config: NotificationConfiguration) {
                self.config = config
            }
        }
    }
}

protocol NotificationDisplayable {
    func showNotification(with configuration: NotificationConfiguration)
    func hideNotification(_ view: UIView)
}

protocol NotificationConfigurable {
    var text: String { get }
    var tapCallback: ((UIView) -> Void)? { get }
    var autoDismissable: Bool { get }
}

struct NotificationConfiguration: NotificationConfigurable {
    var text: String
    var autoDismissable: Bool = true
    var tapCallback: ((UIView) -> Void)?

    init(text: String,
                autoDismissable: Bool = true,
                tapCallback: ((UIView) -> Void)? = nil) {
        self.text = text
        self.tapCallback = tapCallback
        self.autoDismissable = autoDismissable
    }
}
