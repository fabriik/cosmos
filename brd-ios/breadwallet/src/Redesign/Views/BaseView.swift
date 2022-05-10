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
        backgroundColor = .clear
    }
    
    func prepareForReuse() {
        self.config = nil
        self.viewModel = nil
    }
}
