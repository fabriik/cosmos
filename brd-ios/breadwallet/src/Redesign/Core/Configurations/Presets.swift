// 
//  Presets.swift
//  breadwallet
//
//  Created by Rok on 11/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

// TODO: unify with designs (and prolly add more presets)
struct Presets {
    
    struct Label {
        static var primary = LabelConfiguration(font: .boldSystemFont(ofSize: 15), textColor: .red)
        static var secondary = LabelConfiguration(font: .boldSystemFont(ofSize: 15), textColor: .red)
    }
    
    struct Button {
        static var primary = ButtonConfiguration(backgroundConfiguration: .init(backgroundColor: .yellow, tintColor: .black),
                                                 selectedConfiguration: .init(backgroundColor: .black, tintColor: .yellow),
                                                 disabledConfiguration: .init(backgroundColor: .red, tintColor: .white),
                                                 borderConfiguration: .init(tintColor: .pink, borderWidth: 1, cornerRadius: .halfRadius),
                                                 shadowConfiguration: .init(color: .blue, opacity: .highest, offset: .init(width: 10, height: 10), cornerRadius: .halfRadius))
        
        static var secondary = ButtonConfiguration(backgroundConfiguration: .init(backgroundColor: .green, tintColor: .white),
                                                   selectedConfiguration: .init(backgroundColor: .white, tintColor: .green),
                                                   disabledConfiguration: .init(backgroundColor: .white, tintColor: .black),
                                                   shadowConfiguration: .init(color: .blue, opacity: .highest, offset: .init(width: 10, height: 10), cornerRadius: .halfRadius))
    }
    
    struct Image {
        static var primary = ImageViewConfiguration(backgroundColor: .yellow, tintColor: .blue)
        static var secondary = ImageViewConfiguration(backgroundColor: .blue, tintColor: .yellow)
    }
}
