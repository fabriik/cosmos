//
//  TextFieldConfigurable.swift
//  
//
//  Created by Rok Cresnik on 28/09/2021.
//

import Foundation

protocol TextFieldConfigurable {
    associatedtype ImageViewConfig: ImageViewConfigurable
    associatedtype LabelConfig: LabelConfigurable
    associatedtype TextConfig: TextConfigurable
    associatedtype AccessoryConfig: AccessoryConfigurable
    
    var leadingImageConfiguration: ImageViewConfig { get }
    var titleConfiguration: LabelConfig { get }
    var textConfiguration: TextConfig { get }
    var placeholderConfiguration: TextConfig? { get }
    var hintConfiguration: LabelConfig { get }
    
    var trailingAccessoryConfiguration: AccessoryConfig { get }
}
