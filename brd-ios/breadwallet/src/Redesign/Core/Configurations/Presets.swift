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

extension BackgroundConfiguration {
    mutating func withBorder(border: BorderConfiguration?) -> BackgroundConfiguration {
        self.border = border
        return self
    }
}

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
            static var normal = BackgroundConfiguration(tintColor: LightColors.Link.one)
            static var selected = BackgroundConfiguration(tintColor: LightColors.Link.one)
            static var disabled = BackgroundConfiguration(tintColor: LightColors.InteractionPrimary.disabled)
            static var error = BackgroundConfiguration(tintColor: .red)
        }
    }
    
    struct Border {
        static var normal = BorderConfiguration(tintColor: LightColors.Outline.one, borderWidth: 1, cornerRadius: .small)
        static var selected = BorderConfiguration(tintColor: LightColors.primary, borderWidth: 1, cornerRadius: .small)
        static var error = BorderConfiguration(tintColor: LightColors.error, borderWidth: 1, cornerRadius: .small)
        static var disabled = BorderConfiguration(tintColor: LightColors.InteractionPrimary.disabled, borderWidth: 1, cornerRadius: .small)
        static var zero = BorderConfiguration(borderWidth: 0, cornerRadius: .small)
    }
    
    // TODO: add as needed
    struct Shadow {
        // TODO: the shadow color is not part of our Color config?
        static var normal = ShadowConfiguration(color: LightColors.Contrast.one,
                                                opacity: .low,
                                                offset: .init(width: 4, height: 10),
                                                cornerRadius: .small)
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
        static var primary = ImageViewConfiguration(tintColor: LightColors.Text.one)
        static var secondary = ImageViewConfiguration(tintColor: LightColors.Text.two)
        static var tertiary = ImageViewConfiguration(tintColor: LightColors.Contrast.two)
    }
}

// TODO: unify presets with designs
extension Presets {
    struct Button {
        static var primary = ButtonConfiguration(backgroundConfiguration: Presets.Background.Primary.normal,
                                                 selectedConfiguration: Presets.Background.Primary.selected,
                                                 disabledConfiguration: Presets.Background.Primary.disabled)
        
        static var secondary = ButtonConfiguration(backgroundConfiguration: Presets.Background.Secondary.selected.withBorder(border: Presets.Border.normal),
                                                   selectedConfiguration: Presets.Background.Secondary.normal.withBorder(border: Presets.Border.normal),
                                                   disabledConfiguration: Presets.Background.Secondary.disabled.withBorder(border: Presets.Border.disabled))
    }
    
    struct TexxtField {
        static var primary = TextFieldConfiguration(leadingImageConfiguration: .init(backgroundColor: .clear, tintColor: LightColors.Icons.two),
                                                    // TODO: extract to LabelConfig when fonts are added
                                                    textConfiguration: Presets.Label.primary,
                                                    placeholderConfiguration: Presets.Label.primary,
                                                    hintConfiguration: Presets.Label.secondary,
                                                    backgroundConfiguration: Presets.Background.Secondary.normal.withBorder(border: Presets.Border.normal),
                                                    selectedBackgroundConfiguration: Presets.Background.Secondary.selected.withBorder(border: Presets.Border.selected),
                                                    disabledBackgroundConfiguration: Presets.Background.Secondary.disabled.withBorder(border: Presets.Border.disabled),
                                                    errorBackgroundConfiguration: Presets.Background.Secondary.error.withBorder(border: Presets.Border.error))
    }
    
    struct InfoView {
        static var primary = InfoViewConfiguration(headerLeadingImage: Presets.Image.tertiary,
                                                   headerTitle: Presets.Label.tertiary,
                                                   headerTrailingImage: Presets.Image.tertiary,
                                                   title: Presets.Label.tertiary,
                                                   description: Presets.Label.contrast,
                                                   button: Presets.Button.primary,
                                                   background: .init(backgroundColor: LightColors.secondary,
                                                                     tintColor: LightColors.Contrast.two),
                                                   shadow: Presets.Shadow.normal)
    }
}
