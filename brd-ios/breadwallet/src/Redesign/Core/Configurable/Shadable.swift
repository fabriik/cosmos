// 
//  Shadable.swift
//  breadwallet
//
//  Created by Rok on 11/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

protocol Shadable {
    func configure(shadow: ShadowConfiguration?)
}

extension Shadable where Self: Marginable {
    
    func configure(shadow: ShadowConfiguration?) {
        guard let shadow = shadow else { return }
        
        marginableView.layer.masksToBounds = false
        marginableView.layer.shadowColor = shadow.color.cgColor
        marginableView.layer.shadowOpacity = shadow.opacity.rawValue
        marginableView.layer.shadowOffset = shadow.offset
        marginableView.layer.shadowRadius = 1
        marginableView.layer.shadowPath = UIBezierPath(roundedRect: marginableView.bounds, cornerRadius: shadow.cornerRadius.rawValue).cgPath
        marginableView.layer.shouldRasterize = true
        marginableView.layer.rasterizationScale = UIScreen.main.scale
    }
}
