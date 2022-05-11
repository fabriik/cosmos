// 
//  WrapperAccessoryView.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

struct Presets {
    
    struct Label {
        static var primary = LabelConfiguration(font: .boldSystemFont(ofSize: 15), textColor: .red)
        static var secondary = LabelConfiguration(font: .boldSystemFont(ofSize: 15), textColor: .red)
    }
    
    struct Button {
        static var primary = ButtonConfiguration(backgroundConfiguration: .init(backgroundColor: .yellow, tintColor: .black),
                                                 selectedConfiguration: .init(backgroundColor: .black, tintColor: .yellow),
                                                 disabledConfiguration: .init(backgroundColor: .red, tintColor: .white),
                                                 borderConfiguration: .init(tintColor: .pink, borderWidth: 1, cornerRadius: .halfRadius),
                                                 shadowConfiguration: .init(color: .blue, opacity: .highest, offset: .init(width: 10, height: 10), cornerRadius: .halfRadius))
        
        static var secondary = ButtonConfiguration(backgroundConfiguration: .init(backgroundColor: .green, tintColor: .white),
                                                   selectedConfiguration: .init(backgroundColor: .white, tintColor: .green),
                                                   disabledConfiguration: .init(backgroundColor: .white, tintColor: .black),
                                                   shadowConfiguration: .init(color: .blue, opacity: .highest, offset: .init(width: 10, height: 10), cornerRadius: .halfRadius))
    }
}

import UIKit

class WrapperAccessoryView<V: UIView>: UITableViewHeaderFooterView, Wrappable, Identifiable, Reusable, Marginable {
    
    // MARK: Wrappable
    public lazy var wrappedView = V()
    
    // MARK: Overrides
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews() {
        contentView.addSubview(wrappedView)
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            wrappedView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            wrappedView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            wrappedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentView.layoutMargins.left),
            wrappedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentView.layoutMargins.top)
        ]
        
        setupCustomMargins(vertical: .large, horizontal: .small)
        NSLayoutConstraint.activate(constraints)
    }
    
    func setup(_ closure: (V) -> Void) {
        closure(wrappedView)
    }
    
    public override func prepareForReuse() {
        wrappedView.removeFromSuperview()
        super.prepareForReuse()
    }
}
