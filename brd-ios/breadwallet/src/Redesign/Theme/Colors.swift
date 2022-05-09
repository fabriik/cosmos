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
    static var primary: UIColor = .red
    static var secondary: UIColor = .yellow
    
    struct Link {
        static var primary: UIColor = .green
        static var secondary: UIColor = .blue
    }
    
    struct Text {
        static var primary = UIColor.color(for: "primary")
        /// zelena yo!
        static var secondary: UIColor = .color(for: "secondary")
    }
}
