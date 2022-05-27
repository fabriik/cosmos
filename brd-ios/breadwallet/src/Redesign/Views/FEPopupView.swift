// 
//  FEPopupView.swift
//  breadwallet
//
//  Created by Rok on 23/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import SnapKit

struct PopupConfiguration: Configurable {
    var background: BackgroundConfiguration?
    var title: LabelConfiguration?
    var body: LabelConfiguration?
    var buttons: [ButtonConfiguration] = []
}
struct PopupViewModel: ViewModel {
    var title: LabelViewModel?
    var body: String?
    var buttons: [ButtonViewModel] = []
}

class FEPopupView: FEView<PopupConfiguration, PopupViewModel> {
    
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.small.rawValue
        return view
    }()
    
    private lazy var titleStack: UIStackView = {
        let view = UIStackView()
        view.spacing = Margins.small.rawValue
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    private lazy var scrollingStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.extraSmall.rawValue
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var closeButton: WrapperView<FEButton> = {
        let view = WrapperView<FEButton>()
        view.wrappedView.setup(with: .init(image: "cancel"))
        view.wrappedView.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return view
    }()

    private lazy var textView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.isSelectable = false
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var buttons: [FEButton] = []
    var closeCallback: (() -> Void)?
    var buttonCallbacks: [() -> Void] = []
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
        }
        content.setupCustomMargins(all: .huge)
        
        mainStack.addArrangedSubview(titleStack)
        titleStack.snp.makeConstraints { make in
            make.height.equalTo(Margins.huge.rawValue)
        }
        titleStack.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().priority(.low)
        }
        
        titleStack.addArrangedSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.width.equalTo(closeButton.snp.height)
        }
        closeButton.content.setupCustomMargins(all: .extraSmall)
        
        mainStack.addArrangedSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.height.equalTo(Int.max).priority(.low)
        }
        scrollView.addSubview(scrollingStack)
        scrollingStack.snp.makeConstraints { make in
            make.leading.trailing.equalTo(mainStack).inset(Margins.extraSmall.rawValue)
            make.top.bottom.equalToSuperview()
        }
        
        scrollingStack.addArrangedSubview(textView)
    }
    
    override func configure(with config: PopupConfiguration?) {
        guard let config = config else { return }
        super.configure(with: config)
        
        titleLabel.configure(with: config.title)
        configure(background: config.background)
        
        closeButton.wrappedView.configure(with: Presets.Button.icon)
        // create buttons if missing
        guard buttons.count != config.buttons.count else {
            // reconfig?
            return
        }
        
        // remove previous ones, if exist
        buttons.forEach { $0.removeFromSuperview() }
        buttons = []
        
        for config in config.buttons {
            let button = FEButton()
            button.configure(with: config)
            button.snp.makeConstraints { make in
                make.height.equalTo(Margins.extraHuge.rawValue)
            }
            button.isHidden = true
            scrollingStack.addArrangedSubview(button)
            buttons.append(button)
        }
    }
    
    override func setup(with viewModel: PopupViewModel?) {
        guard let viewModel = viewModel else { return }

        super.setup(with: viewModel)
        titleLabel.setup(with: viewModel.title)
        titleLabel.isHidden = viewModel.title == nil
        
        textView.text = viewModel.body
        textView.isHidden = viewModel.body == nil
        textView.sizeToFit()
        
        // if this happens.. its a human mistake :D
        guard buttons.count == viewModel.buttons.count else {
            scrollView.snp.makeConstraints { make in
                make.height.equalTo(textView.contentSize.height)
            }
            return
        }
        for (button, model) in zip(buttons, viewModel.buttons) {
            button.setup(with: model)
            button.isHidden = false
            button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        }
        
        let count = Double(buttons.count)
        var newHeight = textView.contentSize.height
        newHeight += count * (Margins.extraHuge.rawValue + Margins.extraSmall.rawValue)
        
        scrollView.snp.makeConstraints { make in
            make.height.equalTo(newHeight)
        }
    }
    
    override func configure(background: BackgroundConfiguration? = nil) {
        guard let border = background?.border else { return }
        let content = content
        
        content.backgroundColor = background?.backgroundColor
        content.layer.masksToBounds = true
        content.layer.cornerRadius = border.cornerRadius.rawValue
        content.layer.borderWidth = border.borderWidth
        content.layer.borderColor = border.tintColor.cgColor
    }
    
    @objc private func closeTapped() {
        closeCallback?()
    }
    
    @objc private func buttonTapped(sender: FEButton) {
        guard let index = buttons.firstIndex(where: { $0 == sender }),
              index < buttonCallbacks.count
        else { return }
        
        buttonCallbacks[index]()
    }
}
