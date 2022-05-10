//
//  ImageViewConfigurable.swift
//  
//
//  Created by Rok Cresnik on 28/09/2021.
//

import Foundation

protocol ImageViewConfigurable {
    associatedtype BackgroundConfig: BackgorundConfigurable
    
    var backgroundConfiguration: BackgroundConfig { get }
}
