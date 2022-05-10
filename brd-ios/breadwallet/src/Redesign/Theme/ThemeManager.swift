// 
//  ThemeManager.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class ThemeManager {
    private var dict: NSDictionary
    
    static var shared = ThemeManager()
    
    init() {
        guard let path = Bundle.main.path(forResource: "theme", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path)
        else {
            fatalError("Theme.plist error")
        }
        self.dict = dict
    }
    
    func color(for key: String) -> UIColor {
        guard let colors = dict["colors"] as? [String: String],
              let color = colors[key]
        else {
            return .clear
        }   
        return UIColor(hex: color)
    }
    
    func font(for key: String, size: CGFloat) -> UIFont {
        // TODO: return proper font
        return .systemFont(ofSize: 12)
    }
}
