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

extension Presets {
    
    struct Popup {
        static var normal = PopupConfiguration(background: Presets.Background.Primary.normal)
    }
}

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
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.small.rawValue
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()

    private lazy var textView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.isSelectable = false
        view.isScrollEnabled = false
        
        return view
    }()
    
    private lazy var buttonStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.extraSmall.rawValue
        
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
        }
        
        stack.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(Margins.medium.rawValue)
        }
        
        stack.addArrangedSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.height.equalTo(Margins.zero.rawValue)
        }
        
        scrollView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(stack)
        }
//        scrollView.addSubview(buttonStack)
    }
    
    override func configure(with config: PopupConfiguration?) {
        super.configure(with: config)
        titleLabel.configure(with: config?.title)
        configure(background: config?.background)
    }
    
    override func setup(with viewModel: PopupViewModel?) {
        guard let viewModel = viewModel,
        let text = viewModel.body else { return }

        super.setup(with: viewModel)
        titleLabel.setup(with: viewModel.title)
        titleLabel.isHidden = viewModel.title == nil
        
        textView.text = text + text + text + text + text + text + text + text
        textView.sizeToFit()
        scrollView.snp.updateConstraints { make in
            make.height.equalTo(textView.contentSize.height)
        }
    }
    
    override func configure(background: BackgroundConfiguration? = nil) {
        guard let border = background?.border else { return }
        let content = content
        
        content.layer.masksToBounds = true
        content.layer.cornerRadius = border.cornerRadius.rawValue
        content.layer.borderWidth = border.borderWidth
        content.layer.borderColor = border.tintColor.cgColor
    }
}
