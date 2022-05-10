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

struct Colors {
    /// Default text color
    static var primary: UIColor = .red
    /// Secondary text color
    static var secondary: UIColor = .yellow
    
    struct Background {
        /// Default page background
        static var primary = UIColor.color(for: "primary")
        /// Secondary background
        static var secondary = UIColor.color(for: "primary")
    }
                                             
    struct Link {
        /// Primary interactive color. Always the 500 value for the corresponding brand color
        static var primary: UIColor = .green
        /// Secondary ui elements such as toast notifications.
        static var secondary: UIColor = .blue
    }
    
    struct Text {
        /// Primary text; Body copy; Headers; Hover text color for light-text-02
        static var primary = UIColor.color(for: "primary")
        /// Secondary text;Input labels
        static var secondary = UIColor.color(for: "secondary")
    }
}
