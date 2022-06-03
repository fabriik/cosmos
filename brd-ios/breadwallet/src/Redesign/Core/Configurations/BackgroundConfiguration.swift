// 
//  BackgroundConfiguration.swift
//  breadwallet
//
//  Created by Rok on 16/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct BackgroundConfiguration: BackgorundConfigurable {
    var backgroundColor: UIColor = .clear
    var tintColor: UIColor?
    
    var border: BorderConfiguration?
}

extension BackgroundConfiguration {
    mutating func withBorder(border: BorderConfiguration?) -> BackgroundConfiguration {
        self.border = border
        return self
    }
    
    mutating func withCornerRadius(radius: CornerRadius) -> BackgroundConfiguration {
        self.border?.cornerRadius = radius
        return self
    }
}
