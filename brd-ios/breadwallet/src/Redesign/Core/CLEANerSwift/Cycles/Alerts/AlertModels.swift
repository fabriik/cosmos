//
//  AlertConfigurable.swift
//  
//
//  Created by Rok Cresnik on 01/12/2021.
//

import UIKit

enum AlertModels {
    enum Alerts {
        struct ViewAction {}

        struct ActionResponse {
            var alert: AlertViewModel?
        }

        struct ResponseDisplay {
            let model: AlertViewModel
            let config: AlertConfiguration
        }
    }
}
