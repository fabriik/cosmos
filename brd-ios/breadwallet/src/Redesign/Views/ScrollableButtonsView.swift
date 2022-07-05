// 
//  ScrollableButtonsView.swift
//  breadwallet
//
//  Created by Rok on 03/06/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import SnapKit
import CoreMedia

struct ScrollableButtonsConfiguration: Configurable {
    var background: BackgroundConfiguration?
    var buttons: [ButtonConfiguration] = []
}

struct ScrollableButtonsViewModel: ViewModel {
    var buttons: [ButtonViewModel] = []
}

class ScrollableButtonsView: FEView<ScrollableButtonsConfiguration, ScrollableButtonsViewModel> {
    
    var callbacks: [(() -> Void)] = []
    // MARK: callbacks:
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.spacing = Margins.small.rawValue
        view.distribution = .fillEqually
        return view
    }()
    
    private var buttons: [FEButton] = []
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(ButtonHeights.common.rawValue)
        }
        content.setupClearMargins()
        
        scrollView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
    }
    
    override func configure(with config: ScrollableButtonsConfiguration?) {
        buttons.forEach { $0.removeFromSuperview() }
        buttons = []
        
        super.configure(with: config)
        
        setupButtons()
        
        guard let config = config else { return }
        configure(background: config.background)
    }
    
    override func setup(with viewModel: ScrollableButtonsViewModel?) {
        buttons.forEach { $0.removeFromSuperview() }
        buttons = []
        
        super.setup(with: viewModel)
        
        setupButtons()
    }
    
    private func setupButtons() {
        guard let viewModel = viewModel, let config = config else { return }
        
        for (index, model) in viewModel.buttons.enumerated() {
            let button = FEButton()
            
            var buttonConfig: ButtonConfiguration?
            if index < config.buttons.count {
                buttonConfig = config.buttons[index]
            } else {
                buttonConfig = config.buttons.last
            }
            
            button.configure(with: buttonConfig)
            button.setup(with: model)
            buttons.append(button)
            stack.addArrangedSubview(button)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        
        stack.layoutIfNeeded()
    }
    
    // MARK: - User interaction
    @objc private  func buttonTapped(_ sender: FEButton) {
        guard let index = buttons.firstIndex(where: { $0 == sender }) else { return }
        
        if index >= callbacks.count {
            callbacks.last?()
        } else {
            callbacks[index]()
        }
    }
}
