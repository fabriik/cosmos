// 
//  WrapperView.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class WrapperView<V: ViewProtocol>: BaseView<V.C, V.VM>,
                                    Wrappable,
                                    SubviewConfigurable {

    // MARK: Lazy UI
    lazy var wrappedView = V()

    // MARK: - Overrides
    override var tintColor: UIColor! {
        didSet {
            wrappedView.tintColor = tintColor
        }
    }

    override func setupSubviews() {
        super.setupSubviews()
        content.addSubview(wrappedView)
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            wrappedView.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            wrappedView.centerYAnchor.constraint(equalTo: content.centerYAnchor),
            wrappedView.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: content.layoutMargins.left),
            wrappedView.topAnchor.constraint(equalTo: content.topAnchor, constant: content.layoutMargins.top)
        ]
        NSLayoutConstraint.activate(constraints)
        setupClearMargins()
    }

    public func configureSubviews(configure: (V) -> Void) {
        configure(wrappedView)
    }

    override func configure(with config: V.C?) {
        super.configure(with: config)
        wrappedView.configure(with: config)
    }

    override func setup(with viewModel: V.VM?) {
        super.setup(with: viewModel)
        wrappedView.setup(with: viewModel)
    }

    override func prepareForReuse() {
        defer {
            super.prepareForReuse()
        }

        guard let reusable = wrappedView as? Reusable else { return }
        reusable.prepareForReuse()
    }
}
