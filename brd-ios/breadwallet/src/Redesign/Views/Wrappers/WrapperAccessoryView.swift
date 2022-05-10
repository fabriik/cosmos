// 
//  WrapperAccessoryView.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class WrapperAccessoryView<V: UIView>: UITableViewHeaderFooterView, Wrappable, Identifiable, Reusable, Marginable {
    
    // MARK: Wrappable
    public lazy var wrappedView = V()
    
    // MARK: Overrides
    func setupSubviews() {
        contentView.addSubview(wrappedView)
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            wrappedView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            wrappedView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            wrappedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentView.layoutMargins.left),
            wrappedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentView.layoutMargins.top)
        ]
        
        NSLayoutConstraint.activate(constraints)
        setupClearMargins()
    }
    
    func setup(_ closure: (V) -> Void) {
        closure(wrappedView)
    }
    
    public override func prepareForReuse() {
        wrappedView.removeFromSuperview()
        super.prepareForReuse()
    }
}
