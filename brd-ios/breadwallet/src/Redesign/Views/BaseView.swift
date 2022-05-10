// 
//  BaseView.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class BaseView<C: Configurable, M: ViewModel>: UIView,
                                               ViewProtocol,
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
        guard viewModel != nil else { return }
        
        addSubview(content)
//        content.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        setupClearMargins()
    }
    
    func setup(with viewModel: M?) {
        self.viewModel = viewModel
    }
    
    func configure(with config: C?) {
        self.config = config
        backgroundColor = .clear
    }
    
    func prepareForReuse() {
        self.config = nil
        self.viewModel = nil
        content.subviews.forEach { $0.removeFromSuperview() }
        content.removeFromSuperview()
    }
    
    func configureBackground(background: BackgorundConfigurable? = nil,
                                    border: BorderConfigurable? = nil,
                                    shadow: ShadowConfigurable? = nil) {
        content.backgroundColor = background?.backgroundColor

        let cornerRadius = border?.cornerRadius ?? shadow?.cornerRadius ?? .zero

        let radius: CGFloat
        switch cornerRadius {
        case .zero,
                .halfRadius:
            radius = cornerRadius.rawValue

        case .fullRadius:
            radius = content.frame.height * cornerRadius.rawValue
        }

        // CornerRadius
        if let config = border {
            content.layer.masksToBounds = true
            content.layer.cornerRadius = radius
            content.layer.borderWidth = config.borderWidth
            content.layer.borderColor = config.tintColor.cgColor
        }

        if let config = shadow {
            content.layer.masksToBounds = false
            content.layer.shadowColor = config.color.cgColor
            content.layer.shadowOpacity = config.opacity.rawValue
            content.layer.shadowOffset = config.offset
            content.layer.shadowRadius = 1
            content.layer.shadowPath = UIBezierPath(roundedRect: marginableView.bounds, cornerRadius: radius).cgPath
            content.layer.shouldRasterize = true
            content.layer.rasterizationScale = UIScreen.main.scale
        }
    }
}

