//
//  CurrencyExtensions.swift
//  breadwalletWidgetExtension
//
//  Created by stringcode on 18/02/2021.
//  Copyright © 2021 Breadwinner AG. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import SwiftUI

extension Currency {
    var noBgImage: Image {
        guard let uiImage = UIImage(named: "\(code.lowercased())-white-no-bg") else { return Currency.placeholderImage }
        
        return Image(uiImage: uiImage)
    }
    
    var bgImage: Image {
        guard let uiImage = UIImage(named: "\(code.lowercased())-white-square-bg") else { return Currency.placeholderImage }
        
        return Image(uiImage: uiImage)
    }
    
    class var placeholderImage: Image {
        return Image("token-placeholder")
    }
}
