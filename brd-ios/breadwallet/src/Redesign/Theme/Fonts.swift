//
// Created by Equaleyes Solutions Ltd
//

import UIKit

struct Fonts {
    
    static var caption = ThemeManager.shared.font(for: "Roboto-Regular", size: 12)
    static var button = ThemeManager.shared.font(for: "Degular-Semibold", size: 16)
    static var overline = ThemeManager.shared.font(for: "Roboto-Regular", size: 12)
    
    struct Title {
        static var one = ThemeManager.shared.font(for: "Degular-Sembold", size: 36)
        static var two = ThemeManager.shared.font(for: "Degular-Sembold", size: 32)
        static var three = ThemeManager.shared.font(for: "Degular-Semibold", size: 28)
        static var four = ThemeManager.shared.font(for: "Degular-Semibold", size: 24)
        static var five = ThemeManager.shared.font(for: "Degular-Semibold", size: 20)
        static var six = ThemeManager.shared.font(for: "Degular-Semibold", size: 16)
    }
    
    struct Subtitle {
        static var one = ThemeManager.shared.font(for: "Roboto-Medium", size: 16)
        static var two = ThemeManager.shared.font(for: "Roboto-Medium", size: 14)
    }
    
    struct Body {
        static var one = ThemeManager.shared.font(for: "Roboto-Regular", size: 16)
        static var two = ThemeManager.shared.font(for: "Roboto-Regular", size: 14)
    }
    
    struct AlertActionSheet {
        static var title = ThemeManager.shared.font(for: "Roboto-Medium", size: 32)
        static var body = ThemeManager.shared.font(for: "Roboto-Regular", size: 16)
    }
}
