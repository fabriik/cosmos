// 
//  Colors.swift
//  breadwallet
//
//  Created by Rok on 09/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct LightColors {
    
    /// Primary interactive color. Always the 500 value for the corresponding brand color
    static var primary = ThemeManager.shared.color(for: "primary")
    /// Secondary ui elements such as toast notifications
    static var secondary = ThemeManager.shared.color(for: "secondary")
    /// Low contrast shade to be combined with primary colors whenever needed
    static var tertiary = ThemeManager.shared.color(for: "tertiary")
    /// Error message text, icons & backgrounds
    static var error = ThemeManager.shared.color(for: "error")
    /// Success message text, icons & backgrounds
    static var success = ThemeManager.shared.color(for: "success")
    
    struct Background {
        /// Default page background
        static var primary = ThemeManager.shared.color(for: "background-01")
        /// Secondary background
        static var secondary = ThemeManager.shared.color(for: "background-02")
        /// Background for UI elements such as cards, modals, dialogue notifications
        static var tertiary = ThemeManager.shared.color(for: "background-03")
    }
    
    struct Link {
        /// Primary interactive color. Always the 500 value for the corresponding brand color
        static var primary = ThemeManager.shared.color(for: "link-01")
        /// Secondary ui elements such as toast notifications.
        static var secondary = ThemeManager.shared.color(for: "link-02")
    }
    
    struct Text {
        /// Primary text; Body copy; Headers; Hover text color for light-text-02
        static var primary = ThemeManager.shared.color(for: "text-01")
        /// Secondary text; Input labels
        static var secondary = ThemeManager.shared.color(for: "text-02")
    }
    
    struct Contrast {
        /// Text of icons on top of primary colors
        static var primary = ThemeManager.shared.color(for: "contrast-01")
        /// Text or icons on top of secondary, colors and diabled CTAS
        static var secondary = ThemeManager.shared.color(for: "contrast-02")
        /// Text or icons on top of alert or success colors
        static var tertiary = ThemeManager.shared.color(for: "contrast-03")
    }
    
    struct Outline {
        /// Default line elements
        static var primary = ThemeManager.shared.color(for: "outline-01")
        /// Structural line elements
        static var secondary = ThemeManager.shared.color(for: "outline-02")
        /// Selected or hover line elements
        static var tertiary = ThemeManager.shared.color(for: "outline-03")
    }
    
    struct Icons {
        /// Icons
        static var primary = ThemeManager.shared.color(for: "icons-01")
        /// Icons in default colors
        static var secondary = ThemeManager.shared.color(for: "icons-02")
    }
    
    struct InteractionPrimary {
        /// hover
        static var hover = ThemeManager.shared.color(for: "interaction-primary-hover")
        /// pressed
        static var pressed = ThemeManager.shared.color(for: "interaction-primary-pressed")
        /// selected
        static var selected = ThemeManager.shared.color(for: "interaction-primary-selected")
        /// focused
        static var focused = ThemeManager.shared.color(for: "interaction-primary-focused")
        /// disabled
        static var disabled = ThemeManager.shared.color(for: "interaction-primary-disabled")
        /// hover on list items
        static var listingHover = ThemeManager.shared.color(for: "interaction-listing-hover")
    }
}

struct LightInversedColors {
    
    /// Error message text, icons & backgrounds on light-inverse-background-01
    static var error = ThemeManager.shared.color(for: "inverse-error")
    /// Success message text, icons & backgrounds on light-inverse-background-01
    static var success = ThemeManager.shared.color(for: "inverse-success")
    
    struct Background {
        /// Default page background
        static var primary = ThemeManager.shared.color(for: "inverse-background-01")
    }
    
    struct Link {
        /// Primary links, ghost button on light-inverse-background-01
        static var primary = ThemeManager.shared.color(for: "inverse-link-01")
    }
    
    struct Text {
        /// Primary text; Body copy; Headers; Hover text color for light-inverse-text-02 on light-inverse-background-01
        static var primary = ThemeManager.shared.color(for: "inverse-text-01")
        /// Secondary text; Input labels on light-inverse-background-01
        static var secondary = ThemeManager.shared.color(for: "inverse-text-02")
    }
    
    struct Contrast {
        /// Text or icons on top of alert or success colors
        static var tertiary = ThemeManager.shared.color(for: "inverse-contrast-03")
    }
    
    struct Outline {
        /// Default line elements on light-inverse-background-01
        static var primary = ThemeManager.shared.color(for: "inverse-outline-01")
        /// Structural line elements on light-inverse-background-01
        static var secondary = ThemeManager.shared.color(for: "inverse-outline-02")
        /// Selected or hover line elements on light-inverse-background-01
        static var tertiary = ThemeManager.shared.color(for: "inverse-outline-03")
    }
    
    struct Icons {
        /// Icons in default colors
        static var primary = ThemeManager.shared.color(for: "inverse-icons-01")
        /// Icons in default colors
        static var secondary = ThemeManager.shared.color(for: "inverse-icons-02")
    }
}
