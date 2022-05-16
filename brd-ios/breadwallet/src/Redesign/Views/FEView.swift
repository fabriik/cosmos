// 
//  FEView.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct BackgroundConfiguration: BackgorundConfigurable {
    var backgroundColor: UIColor
    var tintColor: UIColor
}

class FEView<C: Configurable, M: ViewModel>: UIView,
                                             ViewProtocol,
                                             Marginable,
                                             Shadable,
                                             Borderable,
                                             Reusable {
    // MARK: NCViewProtocol
    var config: C?
    var viewModel: M?
    
    // MARK: Lazy UI
    lazy var content: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - Initializers
    required override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init(config: C) {
        self.config = config
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    // MARK: View setup
    func setupSubviews() {
        addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            content.leftAnchor.constraint(equalTo: leftAnchor, constant: layoutMargins.left),
            content.rightAnchor.constraint(equalTo: rightAnchor, constant: -layoutMargins.right),
            content.topAnchor.constraint(equalTo: topAnchor, constant: layoutMargins.top),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -layoutMargins.bottom)
        ]
        setupClearMargins()
        NSLayoutConstraint.activate(constraints)
    }
    
    func setup(with viewModel: M?) {
        self.viewModel = viewModel
    }
    
    func configure(with config: C?) {
        self.config = config
        let config = config as? BackgroundConfiguration

        content.backgroundColor = config?.backgroundColor
        content.tintColor = config?.tintColor
    }
    
    func prepareForReuse() {
        config = nil
        viewModel = nil
    }
    
    func configure(shadow: ShadowConfiguration?) {
        guard let shadow = shadow else { return }
        content.layoutIfNeeded()
        
        content.layer.masksToBounds = false
        content.layer.shadowColor = shadow.color.cgColor
        content.layer.shadowOpacity = shadow.opacity.rawValue
        content.layer.shadowOffset = shadow.offset
        content.layer.shadowRadius = 1
        content.layer.shadowPath = UIBezierPath(roundedRect: content.bounds, cornerRadius: shadow.cornerRadius.rawValue).cgPath
        content.layer.shouldRasterize = true
        content.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func configure(border: BorderConfiguration?, backgroundConfiguration: BackgroundConfiguration? = nil) {
        guard let border = border else { return }
        
        content.layer.masksToBounds = true
        content.layer.cornerRadius = border.cornerRadius.rawValue
        content.layer.borderWidth = border.borderWidth
        content.layer.borderColor = backgroundConfiguration?.tintColor.cgColor ?? border.tintColor.cgColor
    }
}
