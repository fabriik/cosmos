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
            static var normal = BackgroundConfiguration(backgroundColor: LightColors.primary,
                                                        tintColor: LightColors.Contrast.two,
                                                        border: Presets.Border.normal)
            
            static var selected = BackgroundConfiguration(backgroundColor: LightColors.InteractionPrimary.pressed,
                                                          tintColor: LightColors.Contrast.two,
                                                          border: Presets.Border.selected)
            
            static var disabled = BackgroundConfiguration(backgroundColor: LightColors.InteractionPrimary.disabled,
                                                          tintColor: LightColors.Contrast.two,
                                                          border: Presets.Border.disabled)
            
            static var error = BackgroundConfiguration(backgroundColor: LightColors.primary,
                                                       tintColor: .red,
                                                       border: Presets.Border.error)
        }
        
        struct Secondary {
            static var normal = BackgroundConfiguration(tintColor: LightColors.Link.one)
            static var selected = BackgroundConfiguration(tintColor: LightColors.Link.one)
            static var disabled = BackgroundConfiguration(tintColor: LightColors.InteractionPrimary.disabled)
            static var error = BackgroundConfiguration(tintColor: .red)
        }
        
        static var transparent = BackgroundConfiguration(backgroundColor: .clear,
                                                         tintColor: LightColors.primary)
    }
    
    struct Border {
        static var zero = BorderConfiguration(borderWidth: 0, cornerRadius: .medium)
        static var normal = BorderConfiguration(tintColor: LightColors.Outline.one, borderWidth: 1, cornerRadius: .small)
        static var selected = BorderConfiguration(tintColor: LightColors.primary, borderWidth: 1, cornerRadius: .small)
        static var disabled = BorderConfiguration(tintColor: .lightGray, borderWidth: 1, cornerRadius: .small)
        static var error = BorderConfiguration(tintColor: LightColors.error, borderWidth: 1, cornerRadius: .small)
    }
    
    // TODO: add as needed
    struct Shadow {
        // TODO: the shadow color is not part of our Color config?
        
        static var zero = ShadowConfiguration(color: .clear,
                                              opacity: .zero,
                                              offset: .zero,
                                              shadowRadius: .small)
        
        static var normal = ShadowConfiguration(color: LightColors.Contrast.one,
                                                opacity: .low,
                                                offset: .init(width: 4, height: 10),
                                                shadowRadius: .small)
        
        static var light = ShadowConfiguration(color: LightColors.Contrast.one,
                                               opacity: .lowest,
                                               offset: .init(width: 0, height: 8),
                                               shadowRadius: .small)
    }
    
    struct Image {
        static var primary = BackgroundConfiguration(tintColor: LightColors.Text.one)
        static var secondary = BackgroundConfiguration(tintColor: LightColors.Text.two)
        static var tertiary = BackgroundConfiguration(tintColor: LightColors.Contrast.two)
    }
}

extension Presets {
    struct Button {
        static var primary = ButtonConfiguration(backgroundConfiguration: Presets.Background.Primary.normal,
                                                 selectedConfiguration: Presets.Background.Primary.selected,
                                                 disabledConfiguration: Presets.Background.Primary.disabled)
        
        static var secondary = ButtonConfiguration(backgroundConfiguration: Presets.Background.Secondary.selected.withBorder(border: Presets.Border.normal),
                                                   selectedConfiguration: Presets.Background.Secondary.normal.withBorder(border: Presets.Border.normal),
                                                   disabledConfiguration: Presets.Background.Secondary.disabled.withBorder(border: Presets.Border.disabled))
        
        static var icon = ButtonConfiguration(backgroundConfiguration: .init(tintColor: LightColors.Contrast.two),
                                              selectedConfiguration: .init(tintColor: LightColors.Icons.one),
                                              disabledConfiguration: .init(tintColor: LightColors.InteractionPrimary.disabled))
        
        static var link = ButtonConfiguration(backgroundConfiguration: .init(tintColor: LightColors.Link.one),
                                              selectedConfiguration: .init(tintColor: LightColors.Link.two),
                                              disabledConfiguration: .init(tintColor: LightColors.InteractionPrimary.disabled))
        
        static var blackIcon = ButtonConfiguration(backgroundConfiguration: .init(tintColor: LightColors.Contrast.one),
                                              selectedConfiguration: .init(tintColor: LightColors.Icons.one),
                                              disabledConfiguration: .init(tintColor: LightColors.InteractionPrimary.disabled))
    }
}

extension Presets {
    struct TextField {
        static var primary = TextFieldConfiguration(leadingImageConfiguration: .init(backgroundColor: .clear, tintColor: LightColors.Icons.two),
                                                    titleConfiguration: .init(font: Fonts.Body.two, textColor: LightColors.Text.one),
                                                    selectedTitleConfiguration: .init(font: Fonts.caption, textColor: LightColors.Text.two),
                                                    textConfiguration: .init(font: Fonts.Body.two, textColor: LightColors.Text.one),
                                                    placeholderConfiguration: .init(font: Fonts.Body.two, textColor: LightColors.Text.one),
                                                    hintConfiguration: .init(font: Fonts.caption, textColor: LightColors.Text.two),
                                                    backgroundConfiguration: Presets.Background.Secondary.normal.withBorder(border: Presets.Border.normal),
                                                    selectedBackgroundConfiguration: Presets.Background.Secondary.selected.withBorder(border: Presets.Border.selected),
                                                    disabledBackgroundConfiguration: Presets.Background.Secondary.disabled.withBorder(border: Presets.Border.disabled),
                                                    errorBackgroundConfiguration: Presets.Background.Secondary.error.withBorder(border: Presets.Border.error))
        
        static var two = TextFieldConfiguration(titleConfiguration: .init(font: Fonts.Body.two, textColor: LightColors.Text.one),
                                                selectedTitleConfiguration: .init(font: Fonts.caption, textColor: LightColors.Text.two),
                                                textConfiguration: .init(font: Fonts.Body.two, textColor: LightColors.Text.one),
                                                placeholderConfiguration: .init(font: Fonts.Body.two, textColor: LightColors.Text.one),
                                                hintConfiguration: .init(font: Fonts.caption, textColor: LightColors.Text.two),
                                                trailingImageConfiguration: .init(tintColor: LightColors.Text.two),
                                                backgroundConfiguration: Presets.Background.Secondary.normal.withBorder(border: Presets.Border.normal),
                                                selectedBackgroundConfiguration: Presets.Background.Secondary.selected.withBorder(border: Presets.Border.selected),
                                                disabledBackgroundConfiguration: Presets.Background.Secondary.disabled.withBorder(border: Presets.Border.disabled),
                                                errorBackgroundConfiguration: Presets.Background.Secondary.error.withBorder(border: Presets.Border.error))
        
        static var email = TextFieldConfiguration(leadingImageConfiguration: .init(backgroundColor: .clear, tintColor: LightColors.Icons.two),
                                                  titleConfiguration: .init(font: Fonts.Body.two, textColor: LightColors.Text.one),
                                                  selectedTitleConfiguration: .init(font: Fonts.caption, textColor: LightColors.Text.two),
                                                  textConfiguration: .init(font: Fonts.Body.two, textColor: LightColors.Text.one),
                                                  placeholderConfiguration: .init(font: Fonts.Body.two, textColor: LightColors.Text.one),
                                                  hintConfiguration: .init(font: Fonts.caption, textColor: LightColors.Text.two),
                                                  backgroundConfiguration: Presets.Background.Secondary.normal.withBorder(border: Presets.Border.normal),
                                                  selectedBackgroundConfiguration: Presets.Background.Secondary.selected.withBorder(border: Presets.Border.selected),
                                                  disabledBackgroundConfiguration: Presets.Background.Secondary.disabled.withBorder(border: Presets.Border.disabled),
                                                  errorBackgroundConfiguration: Presets.Background.Secondary.error.withBorder(border: Presets.Border.error),
                                                  autocapitalizationType: UITextAutocapitalizationType.none,
                                                  autocorrectionType: .no,
                                                  keyboardType: .emailAddress)
    }
}

extension Presets {
    struct InfoView {
        static var verification = InfoViewConfiguration(headerLeadingImage: Presets.Image.tertiary,
                                                        headerTitle: .init(font: Fonts.overline, textColor: LightColors.Contrast.two),
                                                        headerTrailing: Presets.Button.icon,
                                                        status: VerificationView.resubmit.status,
                                                        title: .init(font: Fonts.overline, textColor: LightColors.Contrast.two),
                                                        description: .init(font: Fonts.Subtitle.two, textColor: LightColors.Contrast.two),
                                                        button: Presets.Button.primary.withBorder(normal: Presets.Border.zero,
                                                                                                  selected: Presets.Border.selected,
                                                                                                  disabled: Presets.Border.disabled),
                                                        background: .init(backgroundColor: LightColors.secondary,
                                                                          tintColor: LightColors.Contrast.two,
                                                                          border: Presets.Border.zero),
                                                        shadow: Presets.Shadow.normal)
        
        static var pending = InfoViewConfiguration(headerLeadingImage: Presets.Image.tertiary,
                                                   headerTitle: .init(font: Fonts.overline, textColor: LightColors.Contrast.two),
                                                   headerTrailing: Presets.Button.icon,
                                                   status: VerificationView.pending.status,
                                                   title: .init(font: Fonts.overline, textColor: LightColors.Contrast.two),
                                                   description: .init(font: Fonts.Subtitle.two, textColor: LightColors.Contrast.two),
                                                   button: Presets.Button.primary.withBorder(normal: Presets.Border.zero,
                                                                                             selected: Presets.Border.selected,
                                                                                             disabled: Presets.Border.disabled),
                                                   background: .init(backgroundColor: LightColors.secondary,
                                                                     tintColor: LightColors.Contrast.two,
                                                                     border: Presets.Border.zero),
                                                   shadow: Presets.Shadow.normal)
        
        static var verified = InfoViewConfiguration(headerLeadingImage: Presets.Image.tertiary,
                                                    headerTitle: .init(font: Fonts.overline, textColor: LightColors.Contrast.two),
                                                    headerTrailing: Presets.Button.icon,
                                                    status: VerificationView.verified.status,
                                                    title: .init(font: Fonts.overline, textColor: LightColors.Contrast.two),
                                                    description: .init(font: Fonts.Subtitle.two, textColor: LightColors.Contrast.two),
                                                    button: Presets.Button.primary.withBorder(normal: Presets.Border.zero,
                                                                                              selected: Presets.Border.selected,
                                                                                              disabled: Presets.Border.disabled),
                                                    background: .init(backgroundColor: LightColors.secondary,
                                                                      tintColor: LightColors.Contrast.two,
                                                                      border: Presets.Border.zero),
                                                    shadow: Presets.Shadow.normal)
        
        static var declined = InfoViewConfiguration(headerLeadingImage: Presets.Image.tertiary,
                                                    headerTitle: .init(font: Fonts.overline, textColor: LightColors.Contrast.two),
                                                    headerTrailing: Presets.Button.icon,
                                                    status: VerificationView.resubmit.status,
                                                    title: .init(font: Fonts.overline, textColor: LightColors.Contrast.two),
                                                    description: .init(font: Fonts.Subtitle.two, textColor: LightColors.Contrast.two),
                                                    button: Presets.Button.primary.withBorder(normal: Presets.Border.zero,
                                                                                              selected: Presets.Border.selected,
                                                                                              disabled: Presets.Border.disabled),
                                                    background: .init(backgroundColor: LightColors.secondary,
                                                                      tintColor: LightColors.Contrast.two,
                                                                      border: Presets.Border.zero),
                                                    shadow: Presets.Shadow.normal)
        
        static var primary = InfoViewConfiguration(headerLeadingImage: Presets.Image.tertiary,
                                                   headerTitle: .init(font: Fonts.Title.six, textColor: LightColors.Contrast.two),
                                                   headerTrailing: Presets.Button.icon,
                                                   title: .init(font: Fonts.Title.six, textColor: LightColors.Contrast.two),
                                                   description: .init(font: Fonts.Body.two, textColor: LightColors.Contrast.two),
                                                   button: Presets.Button.primary,
                                                   background: .init(backgroundColor: LightColors.secondary,
                                                                     tintColor: LightColors.Contrast.two,
                                                                     border: Presets.Border.zero),
                                                   shadow: Presets.Shadow.normal)
        
        static var error = InfoViewConfiguration(headerLeadingImage: Presets.Image.tertiary,
                                                 headerTitle: .init(font: Fonts.Title.six, textColor: LightColors.Contrast.two),
                                                 headerTrailing: Presets.Button.icon,
                                                 title: .init(font: Fonts.Title.six, textColor: LightColors.Contrast.two),
                                                 description: .init(font: Fonts.Body.two, textColor: LightColors.Contrast.two),
                                                 button: Presets.Button.primary,
                                                 background: .init(backgroundColor: LightColors.secondary,
                                                                   tintColor: LightColors.Contrast.two,
                                                                   border: Presets.Border.zero),
                                                 shadow: Presets.Shadow.normal)
    }
}

extension Presets {
    struct Alert {
        // TODO: not styled yet
        static var one = AlertConfiguration(titleConfiguration: .init(font: Fonts.Title.six, textColor: LightColors.Text.one),
                                            descriptionConfiguration: .init(font: Fonts.Body.two, textColor: LightColors.Text.one),
                                            imageConfiguration: Presets.Image.primary,
                                            buttonConfigurations: [
                                                Presets.Button.primary,
                                                Presets.Button.secondary
                                            ])
    }
}

extension Presets {
    struct Popup {
        static var normal = PopupConfiguration(background: .init(backgroundColor: LightColors.Background.one,
                                                                 tintColor: LightColors.Contrast.two,
                                                                 border: Presets.Border.zero),
                                               title: .init(font: Fonts.Title.five, textColor: LightColors.Icons.one),
                                               body: .init(font: Fonts.Body.one, textColor: LightColors.Icons.one),
                                               buttons: [ Presets.Button.primary.withBorder(normal: Presets.Border.zero,
                                                                                            selected: Presets.Border.selected,
                                                                                            disabled: Presets.Border.disabled),
                                                          Presets.Button.secondary.withBorder(normal: Presets.Border.normal,
                                                                                              selected: Presets.Border.selected,
                                                                                              disabled: Presets.Border.disabled) ]
        )
    }
}

extension Presets {
    
    struct Animation {
        static var duration = 0.25
    }
}

extension Presets {
    struct VerificationView {
        static var none = VerificationConfiguration(shadow: Presets.Shadow.light,
                                                    background: .init(backgroundColor: LightColors.secondary,
                                                                      tintColor: LightColors.Contrast.two,
                                                                      border: Presets.Border.zero),
                                                    title: .init(font: Fonts.Title.five, textColor: LightColors.Contrast.two),
                                                    infoButton: .init(backgroundConfiguration: .init(tintColor: LightColors.Contrast.two),
                                                                      selectedConfiguration: Presets.Background.Secondary.normal,
                                                                      disabledConfiguration: Presets.Background.Secondary.disabled),
                                                    description: .init(font: Fonts.Body.two, textColor: LightColors.Text.two),
                                                    benefits: .init(font: Fonts.Body.two, textColor: LightColors.Contrast.two, textAlignment: .center))
        
        static var resubmit = VerificationConfiguration(shadow: Presets.Shadow.light,
                                                        background: .init(backgroundColor: LightColors.Background.one,
                                                                          tintColor: LightColors.Outline.two,
                                                                          border: Presets.Border.zero),
                                                        title: .init(font: Fonts.Title.five, textColor: LightColors.Text.one),
                                                        status: .init(title: .init(font: Fonts.Body.two,
                                                                                   textColor: LightColors.Contrast.two,
                                                                                   textAlignment: .center),
                                                                      background: .init(backgroundColor: LightColors.error,
                                                                                        tintColor: LightColors.Contrast.two,
                                                                                        border: Presets.Border.zero)),
                                                        infoButton: .init(backgroundConfiguration: Presets.Background.Secondary.normal,
                                                                          selectedConfiguration: Presets.Background.Secondary.selected,
                                                                          disabledConfiguration: Presets.Background.Secondary.disabled),
                                                        description: .init(font: Fonts.Body.two, textColor: LightColors.Text.two),
                                                        benefits: .init(font: Fonts.Body.two, textColor: LightColors.Contrast.two, textAlignment: .center))
        
        static var pending = VerificationConfiguration(shadow: Presets.Shadow.light,
                                                       background: .init(backgroundColor: LightColors.Background.one,
                                                                         tintColor: LightColors.Outline.two,
                                                                         border: Presets.Border.zero),
                                                       title: .init(font: Fonts.Title.five, textColor: LightColors.Text.one),
                                                       status: .init(title: .init(font: Fonts.Body.two,
                                                                                  textColor: LightColors.Contrast.one,
                                                                                  textAlignment: .center),
                                                                     background: .init(backgroundColor: LightColors.pending,
                                                                                       tintColor: LightColors.Contrast.one,
                                                                                       border: Presets.Border.zero)),
                                                       infoButton: .init(backgroundConfiguration: Presets.Background.Secondary.normal,
                                                                         selectedConfiguration: Presets.Background.Secondary.selected,
                                                                         disabledConfiguration: Presets.Background.Secondary.disabled),
                                                       description: .init(font: Fonts.Body.two, textColor: LightColors.Text.two),
                                                       benefits: .init(font: Fonts.Body.two, textColor: LightColors.Contrast.two, textAlignment: .center))
        
        static var verified = VerificationConfiguration(shadow: Presets.Shadow.light,
                                                        background: .init(backgroundColor: LightColors.Background.one,
                                                                          tintColor: LightColors.Outline.two,
                                                                          border: Presets.Border.zero),
                                                        title: .init(font: Fonts.Title.five, textColor: LightColors.Text.one),
                                                        status: .init(title: .init(font: Fonts.Body.two,
                                                                                   textColor: LightColors.Contrast.two,
                                                                                   textAlignment: .center),
                                                                      background: .init(backgroundColor: LightColors.success,
                                                                                        tintColor: LightColors.Contrast.two,
                                                                                        border: Presets.Border.zero)),
                                                        infoButton: .init(backgroundConfiguration: Presets.Background.Secondary.normal,
                                                                          selectedConfiguration: Presets.Background.Secondary.selected,
                                                                          disabledConfiguration: Presets.Background.Secondary.disabled),
                                                        description: .init(font: Fonts.Body.two, textColor: LightColors.Text.two),
                                                        benefits: .init(font: Fonts.Body.two, textColor: LightColors.Contrast.two, textAlignment: .center))
    }
}

extension Presets {
    struct VerificationInfoView {
        // TODO: localize
        static var none = InfoViewModel(kyc: .levelOne, headerTitle: .text("ACCOUNT LIMITS"),
                                        headerTrailing: .init(image: "infoIcon"),
                                        status: VerificationStatus.none,
                                        description: .text("Get full access to your Fabriik wallet"),
                                        button: .init(title: "Verify your account"),
                                        dismissType: .persistent)
        
        static var verified = InfoViewModel(kyc: .levelOne, headerTitle: .text("ACCOUNT LIMITS"),
                                            headerTrailing: .init(image: "infoIcon"),
                                            status: VerificationStatus.levelOne,
                                            description: .text("Current limit: $1,000/day"),
                                            button: .init(title: "Upgrade your limits"),
                                            dismissType: .persistent)
        
        static var pending = InfoViewModel(kyc: .levelOne, headerTitle: .text("ACCOUNT LIMITS"),
                                           headerTrailing: .init(image: "infoIcon"),
                                           status: VerificationStatus.emailPending,
                                           description: .text("We’ll let you know when your account is verified."),
                                           dismissType: .persistent)
        
        static var verifiedLevelTwo = InfoViewModel(kyc: .levelTwo, headerTitle: .text("ACCOUNT LIMITS"),
                                                    headerTrailing: .init(image: "infoIcon"),
                                                    status: VerificationStatus.levelTwo(.levelTwo),
                                                    description: .text("Congratulations! You now have full access to your Fabriik wallet."),
                                                    dismissType: .persistent)
        
        static var resubmit = InfoViewModel(kyc: .levelTwo, headerTitle: .text("ACCOUNT LIMITS"),
                                            headerTrailing: .init(image: "infoIcon"),
                                            status: VerificationStatus.levelTwo(.resubmit),
                                            description: .text("Oops! We had some issues processing your data"),
                                            button: .init(title: "Why is my verification declined?"),
                                            dismissType: .persistent)
        
        static var declined = InfoViewModel(kyc: .levelTwo, headerTitle: .text("ACCOUNT LIMITS"),
                                            headerTrailing: .init(image: "infoIcon"),
                                            status: VerificationStatus.levelTwo(.declined),
                                            description: .text("Oops! We had some issues processing your data"),
                                            button: .init(title: "Why is my verification declined?"),
                                            dismissType: .persistent)
    }
}
