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
    lazy var content = UIView()
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
        addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalTo(snp.margins)
        }
        setupCustomMargins(all: .zero)
        
        content.addSubview(wrappedView)
        wrappedView.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
        }
        content.setupCustomMargins(all: .zero)
        isUserInteractionEnabled = true
        content.isUserInteractionEnabled = true
        wrappedView.isUserInteractionEnabled = true
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
        content.backgroundColor = background?.backgroundColor
        tintColor = background?.tintColor
        
        let radius = border.cornerRadius == .fullRadius ? content.bounds.width / 2 : border.cornerRadius.rawValue
        content.layer.cornerRadius = radius
        content.layer.borderWidth = border.borderWidth
        content.layer.borderColor = border.tintColor.cgColor
        
        content.layer.masksToBounds = false
        content.layer.shadowColor = UIColor.clear.cgColor
        content.layer.shadowOpacity = 0
        content.layer.shadowOffset = .zero
        content.layer.shadowRadius = 0
        content.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        content.layer.shouldRasterize = true
        content.layer.rasterizationScale = UIScreen.main.scale
    }
}
