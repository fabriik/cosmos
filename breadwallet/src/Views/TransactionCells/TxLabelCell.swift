//
//  TxLabelCell.swift
//  breadwallet
//
//  Created by Ehsan Rezaie on 2017-12-20.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit

class TxLabelCell: TxDetailRowCell {
    
    // MARK: - Accessors
    
    public var value: String {
        get {
            return valueLabel.text ?? ""
        }
        set {
            valueLabel.text = newValue
        }
    }

    // MARK: - Views
    
    fileprivate let valueLabel = UILabel(font: UIFont.customMedium(size: 13.0))
    
    // MARK: - Init
    
    override func addSubviews() {
        super.addSubviews()
        container.addSubview(valueLabel)
    }
    
    override func addConstraints() {
        super.addConstraints()
        
        valueLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        valueLabel.constrain([
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: C.padding[1]),
            //titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -C.padding[1]),
            valueLabel.constraint(.trailing, toView: container, constant: -C.padding[2]),
            valueLabel.constraint(.top, toView: container, constant: C.padding[2])
            ])
    }
    
    override func setupStyle() {
        super.setupStyle()
        valueLabel.textColor = .darkText
        valueLabel.textAlignment = .right
    }
}


class TxMemoCell: TxLabelCell {
    
    override func setupStyle() {
        super.setupStyle()
        valueLabel.numberOfLines = 0
        valueLabel.lineBreakMode = .byWordWrapping
    }
}
