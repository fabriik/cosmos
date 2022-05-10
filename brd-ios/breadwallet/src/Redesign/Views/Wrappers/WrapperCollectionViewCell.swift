// 
//  WrapperCollectionViewCell.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class WrapperCollectionCell<T: UIView>: UICollectionViewCell, Marginable, Reusable {
    static var identifier: String {
        return (String(describing: T.self))
    }
    
    // MARK: Variables
    
    var wrappedView = T()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    var shouldHighlight: Bool = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        (wrappedView as? Reusable)?.prepareForReuse()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        contentView.addSubview(wrappedView)
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            wrappedView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            wrappedView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            wrappedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentView.layoutMargins.left),
            wrappedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentView.layoutMargins.top)
        ]
        NSLayoutConstraint.activate(constraints)
        setupCustomMargins(vertical: .zero, horizontal: .small)
    }
    
    func setup(_ closure: (T) -> Void) {
        closure(wrappedView)
    }
}
