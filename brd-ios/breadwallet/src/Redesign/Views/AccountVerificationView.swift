// 
//  AccountVerificationView.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 31.5.22.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import SnapKit

struct AccountVerificationConfiguration: Configurable {
    
}

struct AccountVerificationModel: ViewModel {
    var header: String
    var title: String
    var description: String
    var image: String
    var status: VerificationStatus
}

class AccountVerificationView: FEView<AccountVerificationConfiguration, AccountVerificationModel> {
    
    // MARK: callbacks:
    var editImageCallback: (() -> Void)?
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.large.rawValue
        return view
    }()
    
    private lazy var headerLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var statusView: WrapperView<FELabel> = {
        let view = WrapperView<FELabel>()
        return view
    }()
    
    private lazy var titleStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = Margins.small.rawValue
        
        return view
    }()
    
    private lazy var iconView:WrapperView<FEImageView> = {
        let view = WrapperView<FEImageView>()
        view.wrappedView.setup(with: .init(.imageName("CircleCheckSolid")))
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var arrowImageView: WrapperView<FEImageView> = {
        let view = WrapperView<FEImageView>()
        view.wrappedView.setup(with: .init(.imageName("foward")))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var descriptionLabel: WrapperView<FELabel> = {
        let view = WrapperView<FELabel>()
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        content.addSubview(stack)
        setupCustomMargins(all: .medium)
        stack.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
        }
        
        stack.addArrangedSubview(headerLabel)
        stack.addArrangedSubview(statusView)
        statusView.snp.makeConstraints { make in
            make.leading.equalTo(headerLabel.snp.trailing)
            make.trailing.equalToSuperview()
        }
        stack.addArrangedSubview(titleStack)
        titleStack.addArrangedSubview(iconView)
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(arrowImageView)
        
        stack.addArrangedSubview(descriptionLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeImageTapped))
        arrowImageView.addGestureRecognizer(tap)
    }
    
//    override func configure(with config: ProfileConfiguration?) {
//        super.configure(with: config)
//
//        let zeroBorder = BorderConfiguration(borderWidth: 0, cornerRadius: .fullRadius)
//        imageView.wrappedView.configure(with: .init(backgroundColor: .red, tintColor: LightColors.primary, border: zeroBorder))
//        editImageView.wrappedView.configure(with: Presets.Background.Primary.normal.withBorder(border: zeroBorder))
//        nameLabel.configure(with: .init(font: Fonts.Title.three,
//                                        textColor: LightColors.Text.one,
//                                        textAlignment: .center))
//    }
//    
//    override func setup(with viewModel: ProfileViewModel?) {
//        super.setup(with: viewModel)
//        guard let viewModel = viewModel else { return }
//
//        nameLabel.setup(with: .text(viewModel.name))
//        imageView.wrappedView.setup(with: .imageName(viewModel.image))
//    }
    
    // MARK: - User interaction
    @objc private func changeImageTapped() {
        editImageCallback?()
    }
}
