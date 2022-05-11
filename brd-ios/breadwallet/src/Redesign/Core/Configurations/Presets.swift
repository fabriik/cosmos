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

// TODO: unify with designs and use color / font enums
struct Presets {
    
    struct Background {
        struct Primary {
            static var normal = BackgroundConfiguration(backgroundColor: .white, tintColor: .black)
            static var selected = BackgroundConfiguration(backgroundColor: .gray, tintColor: .black)
            static var disabled = BackgroundConfiguration(backgroundColor: .lightGray, tintColor: .gray)
            static var error = BackgroundConfiguration(backgroundColor: .white, tintColor: .red)
        }
    }
    
    struct Border {
        static var normal = BorderConfiguration(tintColor: .black, borderWidth: 1, cornerRadius: .halfRadius)
        static var zero = BorderConfiguration(tintColor: .clear, borderWidth: 0, cornerRadius: .halfRadius)
    }
    
    struct Shadow {
        static var normal = ShadowConfiguration(color: .cyan, opacity: .highest, offset: .init(width: 30, height: 30), cornerRadius: .halfRadius)
        static var zero = ShadowConfiguration(color: .clear, opacity: .zero, offset: .zero, cornerRadius: .halfRadius)
    }
    
    struct Label {
        static var primary = LabelConfiguration(font: .boldSystemFont(ofSize: 15), textColor: .red)
        static var secondary = LabelConfiguration(font: .boldSystemFont(ofSize: 10), textColor: .gray)
    }
    
    struct Image {
        static var primary = ImageViewConfiguration(backgroundColor: .yellow, tintColor: .blue)
        static var secondary = ImageViewConfiguration(backgroundColor: .blue, tintColor: .yellow)
    }
}

// TODO: unify presets with designs
extension Presets {
    struct Button {
        static var primary = ButtonConfiguration(backgroundConfiguration: Presets.Background.Primary.normal,
                                                 selectedConfiguration: Presets.Background.Primary.selected,
                                                 disabledConfiguration: Presets.Background.Primary.disabled,
                                                 borderConfiguration: Presets.Border.normal,
                                                 shadowConfiguration: Presets.Shadow.normal)
        
        static var secondary = ButtonConfiguration(backgroundConfiguration: Presets.Background.Primary.selected,
                                                   selectedConfiguration: Presets.Background.Primary.normal,
                                                   disabledConfiguration: Presets.Background.Primary.disabled)
    }
    
    struct TexxtField {
        static var primary = TextFieldConfiguration(leadingImageConfiguration: Presets.Image.primary,
                                                    titleConfiguration: Presets.Label.primary,
                                                    textConfiguration: Presets.Label.primary,
                                                    placeholderConfiguration: Presets.Label.secondary,
                                                    hintConfiguration: Presets.Label.primary,
                                                    trailingImageConfiguration: Presets.Image.secondary,
                                                    backgroundConfiguration: Presets.Background.Primary.normal,
                                                    selectedBackgroundConfiguration: Presets.Background.Primary.selected,
                                                    disabledBackgroundConfiguration: Presets.Background.Primary.disabled,
                                                    errorBackgroundConfiguration: Presets.Background.Primary.error,
                                                    shadowConfiguration: Presets.Shadow.normal,
                                                    borderConfiguration: Presets.Border.normal)
        
        static var secondary = TextFieldConfiguration(leadingImageConfiguration: Presets.Image.primary,
                                                    textConfiguration: Presets.Label.secondary,
                                                    placeholderConfiguration: Presets.Label.secondary,
                                                    backgroundConfiguration: Presets.Background.Primary.normal,
                                                    selectedBackgroundConfiguration: Presets.Background.Primary.selected,
                                                    disabledBackgroundConfiguration: Presets.Background.Primary.disabled)
    }
}
