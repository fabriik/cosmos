// 
//  FEButton.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct ButtonConfiguration: Configurable {
    var backgroundConfiguration: BackgroundConfiguration?
    var selectedConfiguration: BackgroundConfiguration?
    var disabledConfiguration: BackgroundConfiguration?
    var borderConfiguration: BorderConfiguration?
    var shadowConfiguration: ShadowConfiguration?
}

struct ButtonViewModel: ViewModel {
    var title: String?
}

class FEButton: UIButton, ViewProtocol, StateDisplayable, Borderable, Shadable {
    
    var config: ButtonConfiguration?
    var viewModel: ButtonViewModel?
    
    override var isSelected: Bool {
        didSet {
            animateTo(state: isSelected ? .selected : .normal)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            animateTo(state: isHighlighted ? .highlighted : .normal)
        }   
    }
    
    override var isEnabled: Bool {
        didSet {
            animateTo(state: isEnabled ? .normal : .disabled)
        }
    }
    
    func configure(with config: ButtonConfiguration?) {
        guard let config = config else { return }

        self.config = config
        backgroundColor = config.backgroundConfiguration?.backgroundColor
        setTitleColor(config.backgroundConfiguration?.tintColor, for: .normal)
        setTitleColor(config.disabledConfiguration?.tintColor, for: .disabled)
        setTitleColor(config.selectedConfiguration?.tintColor, for: .selected)
        setTitleColor(config.selectedConfiguration?.tintColor, for: .highlighted)
        
        // Border
        configure(border: config.borderConfiguration)
        
        // Shadow
        configure(shadow: config.shadowConfiguration)
    }
    
    func setup(with viewModel: ButtonViewModel?) {
        guard let viewModel = viewModel else { return }

        self.viewModel = viewModel
        setTitle(viewModel.title, for: .normal)
    }
    
    func animateTo(state: DisplayState, withAnimation: Bool = true) {
        let background: BackgroundConfiguration?
        
        switch state {
        case .normal:
            background = config?.backgroundConfiguration
            
            // TODO: any need to split?
        case .highlighted, .selected:
            background = config?.selectedConfiguration
            
        case .disabled:
            background = config?.disabledConfiguration
        }
        
        // TODO: constant for duration
        UIView.animate(withDuration: withAnimation ? 0.25 : 0) { [weak self] in
            self?.backgroundColor = background?.backgroundColor
            self?.tintColor = background?.tintColor
        }
    }
}
