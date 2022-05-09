//
//  LabelConfigurable.swift
//  
//
//  Created by Rok Cresnik on 28/09/2021.
//

import Foundation

protocol LabelConfigurable {
    associatedtype BackgroundConfig: BackgorundConfigurable
    associatedtype TextConfig: TextConfigurable
    
    var backgroundConfiguration: BackgroundConfig { get }
    var textConfiguration: TextConfig { get }
}
