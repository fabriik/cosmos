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
import SnapKit

class FEView<C: Configurable, M: ViewModel>: UIView,
                                             ViewProtocol,
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
        content.snp.makeConstraints { make in
            make.edges.equalTo(snp.margins)
        }
        setupCustomMargins(all: .zero)
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
    
    func configure(background: BackgroundConfiguration?) {
        content.backgroundColor = background?.backgroundColor
        content.tintColor = background?.border?.tintColor ?? background?.tintColor

        guard let border = background?.border else { return }

        content.layer.masksToBounds = true
        content.layer.cornerRadius = border.cornerRadius.rawValue
        content.layer.borderWidth = border.borderWidth
        content.layer.borderColor = border.tintColor.cgColor
    }
}