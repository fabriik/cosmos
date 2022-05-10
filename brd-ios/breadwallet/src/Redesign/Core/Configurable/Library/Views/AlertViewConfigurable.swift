//
//  AlertViewConfigurable.swift
//  
//
//  Created by Rok Cresnik on 29/09/2021.
//

import Foundation

protocol AlertViewConfigurable {
    associatedtype ImageViewConfig: ImageViewConfigurable
    associatedtype LabelConfig: LabelConfigurable
    associatedtype BackgroundConfig: BackgorundConfigurable
    associatedtype ButtonConfig: ButtonConfigurable
    
    var imageViewConfiguration: ImageViewConfig { get }
    var titleViewConfiguration: LabelConfig { get }
    var contentViewConfiguration: LabelConfig { get }
    var buttonViewConfigurations: [ButtonConfig] { get }
    var backgroundConfiguration: BackgroundConfig { get }
}
