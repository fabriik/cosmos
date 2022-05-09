//
//  AlertConfigurable.swift
//  
//
//  Created by Rok Cresnik on 01/12/2021.
//

import UIKit

enum AlertModels {
    enum Alerts {
        struct ViewAction {
            init() {}
        }

        struct ActionResponse {
            var alert: Alertable?

            init(alert: Alertable?) {
                self.alert = alert
            }
        }

        struct ResponseDisplay {
            let config: AlertConfigurationModel

            init(config: AlertConfigurationModel) {
                self.config = config
            }
        }
    }
}

struct AlertConfigurationModel {
    
}
