// 
//  UIColor+fromPlist.swift
//  breadwallet
//
//  Created by Rok on 09/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension UIColor {
    
    convenience init(hex: String) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if sanitized.hasPrefix("#") {
            sanitized.remove(at: sanitized.startIndex)
        }
        var rgbValue: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: CGFloat(1.0))
    }
    
    // get color from Theme.plist
    static func color(for key: String) -> UIColor {
        guard let path = Bundle.main.path(forResource: "theme", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let colors = dict["colors"] as? [String: String],
              let color = colors[key]
        else {
            fatalError("Theme.plist error")
        }
        
        return UIColor(hex: color)
    }
}
