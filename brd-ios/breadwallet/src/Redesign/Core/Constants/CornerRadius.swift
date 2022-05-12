//
//  CornerRadius.swift
//  
//
//  Created by Rok Cresnik on 14/09/2021.
//

import UIKit

enum CornerRadius: CGFloat {
    /// Normal square view
    case zero = 0
    /// 8 point radius
    case extraSmall = 8
    /// 10 point radius
    case small = 10
    /// 12 point radius
    case medium = 12
    // 24 point radius
    case large = 24
    /// Rounded view - half height radius (multiply with view height!)
    case fullRadius = 0.5
}
