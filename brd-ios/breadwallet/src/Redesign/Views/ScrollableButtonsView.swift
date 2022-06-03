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
        view.spacing = Margins.large.rawValue
        return view
    }()
    
    private var buttons: [FEButton] = []
    
    override func setupSubviews() {
        super.setupSubviews()
        content.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(28)
        }
        content.setupClearMargins()
        
        scrollView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func configure(with config: ScrollableButtonsConfiguration?) {
        super.configure(with: config)
        guard let config = config else { return }
        configure(background: config.background)
    }
    
    override func setup(with viewModel: ScrollableButtonsViewModel?) {
        super.setup(with: viewModel)
        guard let viewModel = viewModel else { return }
        
        guard buttons.count != viewModel.buttons.count else {
            return
        }
        
        buttons.forEach { $0.removeFromSuperview() }

        setupButtons()
    }
    
    private func setupButtons() {
        guard let viewModel = viewModel,
              let config = config
        else { return }
        
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
            button.backgroundColor = .yellow
            buttons.append(button)
            stack.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.width.equalToSuperview().priority(.low)
                make.height.equalToSuperview()
            }
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        stack.layoutIfNeeded()
    }
    
    // MARK: - User interaction
    @objc private  func buttonTapped(_ sender: FEButton) {
        guard let index = buttons.firstIndex(where: { $0 == sender }) else { return }
        
        if index < callbacks.count {
            callbacks[index]()
        } else {
            callbacks.last?()
        }
    }
}
