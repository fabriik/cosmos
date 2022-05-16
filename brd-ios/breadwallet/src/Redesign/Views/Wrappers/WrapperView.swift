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

    // MARK: Lazy UI
    lazy var content = UIView()
    lazy var wrappedView = T()

    // MARK: - Overrides
    override var tintColor: UIColor! {
        didSet {
            wrappedView.tintColor = tintColor
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    func setupSubviews() {
        addSubview(content)
        content.addSubview(wrappedView)
        content.translatesAutoresizingMaskIntoConstraints = false
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            content.leftAnchor.constraint(equalTo: leftAnchor, constant: layoutMargins.left),
            content.rightAnchor.constraint(equalTo: rightAnchor, constant: -layoutMargins.right),
            content.topAnchor.constraint(equalTo: topAnchor, constant: layoutMargins.top),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -layoutMargins.bottom),
            
            wrappedView.leftAnchor.constraint(equalTo: content.leftAnchor),
            wrappedView.rightAnchor.constraint(equalTo: content.rightAnchor),
            wrappedView.topAnchor.constraint(equalTo: content.topAnchor),
            wrappedView.bottomAnchor.constraint(equalTo: content.bottomAnchor)
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
