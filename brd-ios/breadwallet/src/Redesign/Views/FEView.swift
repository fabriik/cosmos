// 
//  FEView.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

struct ViewConfiguration: Configurable {
    var normal: BackgroundConfiguration?
    var selected: BackgroundConfiguration?
    var disabled: BackgroundConfiguration?
    var error: BackgroundConfiguration?
    
    var border: BorderConfiguration?
    var shadow: ShadowConfiguration?
}

import UIKit

struct BackgroundConfiguration: BackgorundConfigurable {
    var backgroundColor: UIColor
    var tintColor: UIColor
}

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
        content.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            content.centerXAnchor.constraint(equalTo: centerXAnchor),
            content.centerYAnchor.constraint(equalTo: centerYAnchor),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutMargins.left),
            content.topAnchor.constraint(equalTo: topAnchor, constant: layoutMargins.top)
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
}
