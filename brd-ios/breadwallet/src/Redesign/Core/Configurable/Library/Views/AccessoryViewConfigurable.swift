//
//  AccessoryViewConfigurable.swift
//  
//
//  Created by Rok Cresnik on 28/09/2021.
//

import Foundation

protocol AccessoryConfigurable {
    associatedtype ImageViewConfig: ImageViewConfigurable
    associatedtype LabelConfig: LabelConfigurable
    associatedtype ButtonConfig: ButtonConfigurable
    
    var imageConfiguration: ImageViewConfig { get }
    var labelConfiguration: LabelConfig { get }
    var buttonConfiguration: ButtonConfig? { get }
}
