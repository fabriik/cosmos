//
//  ViewProtocol.swift
//
//
//  Created by Rok Cresnik on 06/09/2021.
//

import UIKit

protocol ViewModel {}

protocol ObjectConfigurable: NSObject {
    associatedtype C: Configurable
    
    var config: C? { get set }
    func configure(with config: C?)
}

protocol ObjectViewModelable: NSObject {
    associatedtype VM: ViewModel
    
    var viewModel: VM? { get set }
    func setup(with viewModel: VM?)
}

protocol ViewProtocol: UIView,
                       ObjectConfigurable,
                       ObjectViewModelable,
                       Marginable {
    
    func configureBackground(background: BackgorundConfigurable?,
                             border: BorderConfigurable?,
                             shadow: ShadowConfigurable?)
}

extension ViewProtocol {
    func configureBackground(background: BackgorundConfigurable? = nil,
                             border: BorderConfigurable? = nil,
                             shadow: ShadowConfigurable? = nil) {
        marginableView.backgroundColor = background?.backgroundColor
        
        let cornerRadius = border?.cornerRadius ?? shadow?.cornerRadius ?? .zero
        
        let radius: CGFloat
        switch cornerRadius {
        case .zero,
                .halfRadius:
            radius = cornerRadius.rawValue
            
        case .fullRadius:
            radius = marginableView.frame.height * cornerRadius.rawValue
        }
        
        // CornerRadius
        if let config = border {
            marginableView.layer.masksToBounds = true
            marginableView.layer.cornerRadius = radius
            marginableView.layer.borderWidth = config.borderWidth
            marginableView.layer.borderColor = config.tintColor.cgColor
        }
        
        if let config = shadow {
            marginableView.layer.masksToBounds = false
            marginableView.layer.shadowColor = config.color.cgColor
            marginableView.layer.shadowOpacity = config.opacity.rawValue
            marginableView.layer.shadowOffset = config.offset
            marginableView.layer.shadowRadius = 1
            marginableView.layer.shadowPath = UIBezierPath(roundedRect: marginableView.bounds, cornerRadius: radius).cgPath
            marginableView.layer.shouldRasterize = true
            marginableView.layer.rasterizationScale = UIScreen.main.scale
        }
    }
}
