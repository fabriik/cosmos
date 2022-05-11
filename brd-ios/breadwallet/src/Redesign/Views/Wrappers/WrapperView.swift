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

class WrapperView<T: UIView>: UIView,
                              Wrappable,
                              Marginable,
                              Reusable {
    
    lazy var content = UIView()

    // MARK: Lazy UI
    lazy var wrappedView = T()

    // MARK: - Overrides
    override var tintColor: UIColor! {
        didSet {
            wrappedView.tintColor = tintColor
        }
    }

    func setupSubviews() {
        addSubview(content)
        content.addSubview(wrappedView)
        content.translatesAutoresizingMaskIntoConstraints = false
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            content.centerXAnchor.constraint(equalTo: centerXAnchor),
            content.centerYAnchor.constraint(equalTo: centerYAnchor),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutMargins.left),
            content.topAnchor.constraint(equalTo: topAnchor, constant: layoutMargins.top),
            
            wrappedView.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            wrappedView.centerYAnchor.constraint(equalTo: content.centerYAnchor),
            wrappedView.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            wrappedView.topAnchor.constraint(equalTo: content.topAnchor)
        ]
        setupClearMargins()
        NSLayoutConstraint.activate(constraints)
    }
    
    func setup(_ closure: (T) -> Void) {
        closure(wrappedView)
    }

    func prepareForReuse() {
        guard let reusable = wrappedView as? Reusable else { return }
        reusable.prepareForReuse()
    }
}
