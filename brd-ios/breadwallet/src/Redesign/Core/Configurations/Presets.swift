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
            static var normal = BackgroundConfiguration(backgroundColor: LightColors.primary, tintColor: LightColors.Contrast.secondary)
            static var selected = BackgroundConfiguration(backgroundColor: LightColors.InteractionPrimary.pressed, tintColor: LightColors.Contrast.secondary)
            static var disabled = BackgroundConfiguration(backgroundColor: LightColors.InteractionPrimary.disabled, tintColor: LightColors.Contrast.secondary)
            static var error = BackgroundConfiguration(backgroundColor: LightColors.primary, tintColor: .red)
        }
        struct Secondary {
            static var normal = BackgroundConfiguration(backgroundColor: .clear, tintColor: LightColors.Link.primary)
            static var selected = BackgroundConfiguration(backgroundColor: .clear, tintColor: LightColors.Link.primary)
            static var disabled = BackgroundConfiguration(backgroundColor: .clear, tintColor: LightColors.InteractionPrimary.disabled)
            static var error = BackgroundConfiguration(backgroundColor: .clear, tintColor: .red)
        }
    }
    
    struct Border {
        static var normal = BorderConfiguration(tintColor: LightColors.Outline.primary, borderWidth: 1, cornerRadius: .small)
        static var zero = BorderConfiguration(tintColor: .clear, borderWidth: 0, cornerRadius: .small)
    }
    
    // TODO: add as needed
    struct Shadow {
        // TODO: the shadow color is not part of our Color config?
        static var normal = ShadowConfiguration(color: LightColors.Contrast.primary,
                                                opacity: .low,
                                                offset: .init(width: 4, height: 10),
                                                cornerRadius: .small)
        static var zero = ShadowConfiguration(color: .clear, opacity: .zero, offset: .zero, cornerRadius: .small)
    }
    
    struct Label {
        // TODO: fonts
        static var primary = LabelConfiguration(font: .systemFont(ofSize: 14), textColor: LightColors.Text.primary)
        static var secondary = LabelConfiguration(font: .systemFont(ofSize: 12), textColor: LightColors.Text.secondary)
        static var tertiary = LabelConfiguration(font: .boldSystemFont(ofSize: 16), textColor: LightColors.Contrast.secondary)
        static var contrast = LabelConfiguration(font: .systemFont(ofSize: 14), textColor: LightColors.Contrast.secondary)
    }
    
    struct Image {
        static var primary = ImageViewConfiguration(tintColor: LightColors.Text.primary)
        static var secondary = ImageViewConfiguration(tintColor: LightColors.Text.secondary)
        static var tertiary = ImageViewConfiguration(tintColor: LightColors.Contrast.secondary)
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
        static var primary = TextFieldConfiguration(leadingImageConfiguration: .init(backgroundColor: .clear, tintColor: LightColors.Icons.secondary),
                                                    titleConfiguration: .init(font: Fonts.overline, textColor: LightColors.Text.secondary),
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
        static var primary = InfoViewConfiguration(headerLeadingImage: Presets.Image.tertiary,
                                                   headerTitle: Presets.Label.tertiary,
                                                   headerTrailingImage: Presets.Image.tertiary,
                                                   title: Presets.Label.tertiary,
                                                   description: Presets.Label.contrast,
                                                   button: Presets.Button.primary,
                                                   background: .init(backgroundColor: LightColors.secondary,
                                                                     tintColor: LightColors.Contrast.secondary),
                                                   border: Presets.Border.zero,
                                                   shadow: Presets.Shadow.normal)
    }
}
