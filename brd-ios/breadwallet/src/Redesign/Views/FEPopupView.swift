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
        view.spacing = Margins.small.rawValue
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var closeButton: WrapperView<FEButton> = {
        let view = WrapperView<FEButton>()
        view.wrappedView.setup(with: .init(image: "Close-X-Popup"))
        view.wrappedView.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.content.setupCustomMargins(all: .large)
        return view
    }()

    private lazy var textView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.isSelectable = false
        view.isScrollEnabled = false
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
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
        content.setupCustomMargins(top: .huge, leading: .huge, bottom: .huge, trailing: .huge)
        
        content.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.top.trailing.equalToSuperview()
        }
        
        mainStack.addArrangedSubview(titleStack)
        titleStack.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(Margins.extraHuge.rawValue)
            make.width.equalToSuperview().priority(.low)
        }
        
        mainStack.addArrangedSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.height.equalTo(Int.max).priority(.low)
        }
        scrollView.addSubview(scrollingStack)
        scrollingStack.snp.makeConstraints { make in
            make.leading.trailing.equalTo(mainStack)
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
        
        guard let body = config.body else { return }
        textView.font = body.font
        textView.textColor = body.textColor
        textView.textAlignment = body.textAlignment
        textView.textContainer.lineBreakMode = body.lineBreakMode
    }
    
    override func setup(with viewModel: PopupViewModel?) {
        guard let viewModel = viewModel else { return }

        super.setup(with: viewModel)
        titleLabel.setup(with: viewModel.title)
        titleLabel.isHidden = viewModel.title == nil
        
        textView.text = viewModel.body
        textView.isHidden = viewModel.body == nil
        textView.sizeToFit()
        
        layoutIfNeeded()
        // if this happens.. its a human mistake :D
        
        // remove previous ones, if exist
        buttons.forEach { $0.removeFromSuperview() }
        buttons = []
        
        let buttonHeight = ButtonHeights.common.rawValue
        if viewModel.buttons.isEmpty == false {
            for i in (0...viewModel.buttons.count - 1) {
                guard let buttonConfigs = config?.buttons else { return }
                let model = viewModel.buttons[i]
                let config = buttonConfigs.count <= i ? config?.buttons.last : buttonConfigs[i]
                
                let button = FEButton()
                button.configure(with: config)
                button.snp.makeConstraints { make in
                    make.height.equalTo(buttonHeight)
                }
                button.setup(with: model)
                scrollingStack.addArrangedSubview(button)
                buttons.append(button)
                button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
            }
        }
        
        let count = Double(buttons.count)
        var newHeight = textView.contentSize.height
        newHeight += count * (buttonHeight + scrollingStack.spacing)
        
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
