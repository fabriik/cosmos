//
//  ButtonConfigurable.swift
//  
//
//  Created by Rok Cresnik on 28/09/2021.
//

import Foundation

protocol BaseButtonConfigurable: Configurable {
    associatedtype BackgroundConfig: BackgorundConfigurable
    
    var backgroundConfiguration: BackgroundConfig { get }
    var selectedBackgroundConfiguration: BackgroundConfig { get }
    var disabledBackgroundConfiguration: BackgroundConfig { get }
    
    func configuration(for state: DisplayState) -> BackgroundConfig
}

extension BaseButtonConfigurable {
    func configuration(for state: DisplayState) -> BackgroundConfig {
        switch state {
        case .normal:
            return backgroundConfiguration
            
        case .selected,
                .highlighted:
            return selectedBackgroundConfiguration
            
        case .disabled:
            return disabledBackgroundConfiguration
        }
    }
}

protocol ButtonConfigurable: BaseButtonConfigurable {
    associatedtype LabelConfig: LabelConfigurable
    associatedtype ImageViewConfig: ImageViewConfigurable
    
    var leadingImageConfiguration: ImageViewConfig { get }
    var trailingImageConfiguration: ImageViewConfig { get }
    
    var titleConfiguration: LabelConfig { get }
    var subtitleConfiguration: LabelConfig { get }
}

protocol CheckButtonConfigurable: BaseButtonConfigurable {
    associatedtype ImageViewConfig: ImageViewConfigurable
    
    var imageConfiguration: ImageViewConfig { get }
}
