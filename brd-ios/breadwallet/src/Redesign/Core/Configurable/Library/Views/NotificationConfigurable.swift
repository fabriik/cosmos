//
//  NotificationConfigurable.swift
//  
//
//  Created by Rok Cresnik on 29/09/2021.
//

import Foundation

protocol NotificationConfigurable2: BaseButtonConfigurable {
    associatedtype ImageViewConfig: ImageViewConfigurable
    associatedtype LabelConfig: LabelConfigurable
    associatedtype AccessoryConfig: AccessoryConfigurable
    
    var leadingImageConfiguration: ImageViewConfig { get }
    var titleConfiguration: LabelConfig { get }
    var subtitleConfiguration: LabelConfig { get }
    var trailingAccessoryConfiguration: AccessoryConfig { get }
}
