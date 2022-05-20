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
import SnapKit

class WrapperView<T: UIView>: UIView,
                              Wrappable,
                              Reusable,
                              Borderable {

    // MARK: Lazy UI
    lazy var wrappedView = T()
    private var config: BackgroundConfiguration?

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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configure(background: config)
    }

    func setupSubviews() {
        addSubview(wrappedView)
        wrappedView.snp.makeConstraints { make in
            make.edges.equalTo(snp.margins)
        }
    }
    
    func setup(_ closure: (T) -> Void) {
        closure(wrappedView)
    }

    func prepareForReuse() {
        guard let reusable = wrappedView as? Reusable else { return }
        reusable.prepareForReuse()
    }
    
    func configure(background: BackgroundConfiguration?) {
        
        guard let border = background?.border else { return }
        config = background
        backgroundColor = background?.backgroundColor
        tintColor = background?.tintColor
        layer.masksToBounds = true
        layer.cornerRadius = border.cornerRadius.rawValue
        layer.borderWidth = border.borderWidth
        layer.borderColor = border.tintColor.cgColor
    }
}
