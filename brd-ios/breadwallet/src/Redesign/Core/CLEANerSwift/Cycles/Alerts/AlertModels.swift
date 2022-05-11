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
        }

        struct ResponseDisplay {
            let config: Any
        }
    }
}
