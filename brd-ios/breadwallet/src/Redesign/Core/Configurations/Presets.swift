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
    // TODO: prolly each BG has to have a "borderConfig"
    struct Background {
        struct Primary {
            static var normal = BackgroundConfiguration(backgroundColor: LightColors.primary, tintColor: LightColors.Contrast.two)
            static var selected = BackgroundConfiguration(backgroundColor: LightColors.InteractionPrimary.pressed, tintColor: LightColors.Contrast.two)
            static var disabled = BackgroundConfiguration(backgroundColor: LightColors.InteractionPrimary.disabled, tintColor: LightColors.Contrast.two)
            static var error = BackgroundConfiguration(backgroundColor: LightColors.primary, tintColor: .red)
        }
        struct Secondary {
            static var normal = BackgroundConfiguration(backgroundColor: .clear, tintColor: LightColors.Link.one)
            static var selected = BackgroundConfiguration(backgroundColor: .clear, tintColor: LightColors.Link.one)
            static var disabled = BackgroundConfiguration(backgroundColor: .clear, tintColor: LightColors.InteractionPrimary.disabled)
            static var error = BackgroundConfiguration(backgroundColor: .clear, tintColor: .red)
        }
    }
    
    struct Border {
        static var normal = BorderConfiguration(tintColor: LightColors.Outline.one, borderWidth: 1, cornerRadius: .small)
        static var zero = BorderConfiguration(tintColor: .clear, borderWidth: 0, cornerRadius: .small)
    }
    
    // TODO: add as needed
    struct Shadow {
        static var normal = ShadowConfiguration(color: .cyan, opacity: .highest, offset: .init(width: 30, height: 30), cornerRadius: .small)
        static var zero = ShadowConfiguration(color: .clear, opacity: .zero, offset: .zero, cornerRadius: .small)
    }
    
    struct Label {
        // TODO: fonts
        static var primary = LabelConfiguration(font: .systemFont(ofSize: 14), textColor: LightColors.Text.one)
        static var secondary = LabelConfiguration(font: .systemFont(ofSize: 12), textColor: LightColors.Text.two)
        static var tertiary = LabelConfiguration(font: .boldSystemFont(ofSize: 14), textColor: .white)
        static var contrast = LabelConfiguration(font: .systemFont(ofSize: 14), textColor: LightColors.Contrast.two)
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
                                                 borderConfiguration: Presets.Border.zero)
        
        static var secondary = ButtonConfiguration(backgroundConfiguration: Presets.Background.Secondary.selected,
                                                   selectedConfiguration: Presets.Background.Secondary.normal,
                                                   disabledConfiguration: Presets.Background.Secondary.disabled,
                                                   borderConfiguration: Presets.Border.normal)
    }
    
    struct TexxtField {
        static var primary = TextFieldConfiguration(leadingImageConfiguration: .init(backgroundColor: .clear, tintColor: LightColors.Icons.two),
                                                    // TODO: extract to LabelConfig when fonts are added
                                                    textConfiguration: Presets.Label.primary,
                                                    placeholderConfiguration: Presets.Label.primary,
                                                    hintConfiguration: Presets.Label.secondary,
                                                    backgroundConfiguration: Presets.Background.Secondary.normal,
                                                    selectedBackgroundConfiguration: Presets.Background.Secondary.selected,
                                                    disabledBackgroundConfiguration: Presets.Background.Secondary.disabled,
                                                    errorBackgroundConfiguration: Presets.Background.Secondary.error,
                                                    borderConfiguration: Presets.Border.normal)
    }
    
    struct InfoView {
        static var primary = InfoViewConfiguration(headerLeadingImage: Presets.Image.primary,
                                                   headerTitle: Presets.Label.tertiary,
                                                   headerTrailingImage: Presets.Image.primary,
                                                   title: Presets.Label.tertiary,
                                                   description: Presets.Label.contrast,
                                                   button: Presets.Button.primary,
                                                   background: .init(backgroundColor: LightColors.secondary,
                                                                     tintColor: LightColors.Contrast.two),
                                                   border: Presets.Border.zero,
                                                   shadow: Presets.Shadow.normal)
    }
}
