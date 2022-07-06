//
//  Margins.swift
//  
//
//  Created by Rok Cresnik on 14/09/2021.
//

import UIKit

/// View inset/offset margins
enum Margins: CGFloat {
    /// 0
    case zero = 0
    /// 2
    case minimum = 2
    /// 4
    case extraSmall = 4
    /// 8
    case small = 8
    /// 12
    case medium = 12
    /// 16
    case large = 16
    /// 20
    case extraLarge = 20
    /// 24
    case huge = 24
    /// 32
    case extraHuge = 32
}

enum BorderWidth: CGFloat {
    /// 0
    case zero = 0
    /// 1
    case minimum = 1
}

enum Opacity: Float {
    /// 0
    case zero = 0
    /// 0.08
    case lowest = 0.12
    /// 0.15
    case low = 0.15
    /// 0.30
    case high = 0.3
    /// 0.80
    case highest = 0.8
}

enum ViewSizes: CGFloat {
    /// 20
    case extraSmall = 20.0
    /// 24
    case small = 24.0
    /// 32
    case medium = 32.0
    /// 80
    case large = 80.0
    /// 100
    case extraLarge = 100.0
}

enum FieldHeights: CGFloat {
    /// 48
    case common = 48.0
}

enum ButtonHeights: CGFloat {
    /// 48
    case common = 48.0
}
