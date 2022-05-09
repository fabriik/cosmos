//
//  TableViewHeaderFooterConfigurable.swift
//  
//
//  Created by Rok Cresnik on 28/09/2021.
//

import Foundation

protocol TableViewHeaderFooterConfigurable {
    associatedtype LabelConfig: LabelConfigurable
    associatedtype AccessoryConfig: AccessoryConfigurable
    
    var titleConfiguration: LabelConfig { get }
    var accessoryConfiguration: AccessoryConfig { get }
}
