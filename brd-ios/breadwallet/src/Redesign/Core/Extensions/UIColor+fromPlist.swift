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
    // get color from Theme.plist
    static func color(for key: String) -> UIColor {
        guard let path = Bundle.main.path(forResource: "theme", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let colors = dict["colors"] as? [String: String],
              let color = colors[key]
        else {
            fatalError("Theme.plist error")
        }
        
        return UIColor.fromHex(color)
    }
}
