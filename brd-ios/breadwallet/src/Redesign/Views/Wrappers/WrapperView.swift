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
        content.snp.makeConstraints { make in
            make.edges.equalTo(snp.margins)
        }
        
        content.addSubview(wrappedView)
        wrappedView.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
        }
        content.setupCustomMargins(all: .zero)
        setupCustomMargins(all: .zero)
    }
    
    func setup(_ closure: (T) -> Void) {
        closure(wrappedView)
    }

    func prepareForReuse() {
        guard let reusable = wrappedView as? Reusable else { return }
        reusable.prepareForReuse()
    }
}
