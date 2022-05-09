//
//  BarConfigurable.swift
//  
//
//  Created by Rok Cresnik on 28/09/2021.
//

import Foundation

protocol BarConfigurable {
    associatedtype BacgroundConfig: BackgorundConfigurable
    associatedtype LabelConfig: LabelConfigurable
    
    var backgroundConfiguration: BacgroundConfig { get }
    var isTranslucent: Bool { get }
    var titleConfiguration: LabelConfig { get }
}
