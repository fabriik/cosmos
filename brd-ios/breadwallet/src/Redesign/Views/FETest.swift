// 
//  FETest.swift
//  breadwallet
//
//  Created by Rok on 18/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import SnapKit

struct TestConfiguration: Configurable {
    
}

struct TestModel: ViewModel {
    
}

class FETest: FEView<TestConfiguration, TestModel> {
    
    var reload: (() -> Void)?
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        return stack
    }()
    
    private lazy var top: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var bottom: UIView = {
        let view = UIView()
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(stack)
        stack.addArrangedSubview(top)
        stack.addArrangedSubview(bottom)
        stack.addArrangedSubview(UIView())
        top.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        bottom.snp.makeConstraints { make in
            make.height.equalTo(25)
        }
        
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapped)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    
    @objc func tapped() {
        bottom.isHidden = !bottom.isHidden
        layoutIfNeeded()
        reload?()
    }
    
    override func configure(with config: TestConfiguration?) {
        content.backgroundColor = .yellow
        top.backgroundColor = .red
        bottom.backgroundColor = .green
        stack.backgroundColor = .clear
    }
    
    override func setup(with viewModel: TestModel?) {
        
    }
}
