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
    // TODO: rename?
    /// 12 point radius
    case halfRadius = 12
    /// Rounded view - half height radius (multiply with view height!)
    case fullRadius = 0.5
}
