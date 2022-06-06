// 
//  VerificationView.swift
//  breadwallet
//
//  Created by Rok on 20/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import SnapKit

enum VerificationStatus: String {
    case none
    case levelOne
    case pending
    case levelTwo
    case error
    
    init(rawValue: String?) {
        switch rawValue?.lowercased() {
        case "kyc_basic":
            self = .levelOne
            
        case "kyc_unlimited_submitted":
            self = .pending
    
        case "kyc_unlimited":
            self = .levelTwo
            
        case "kyc_unlimited_declined":
            self = .error
            
        default:
            self = .none
        }
    }
}

struct StatusViewConfiguration: Configurable {
    var title: LabelConfiguration?
    var background: BackgroundConfiguration?
}

struct VerificationConfiguration: Configurable {
    var background: BackgroundConfiguration?
    var title: LabelConfiguration?
    // TODO: custom
    var status: StatusViewConfiguration?
    var infoButton: ButtonConfiguration?
    var description: LabelConfiguration?
    var bottomButton: ButtonConfiguration?
}

struct VerificationViewModel: ViewModel {
    var title: LabelViewModel?
    // TODO: custom
    var status: VerificationStatus
    var infoButton: ButtonViewModel?
    var description: LabelViewModel?
    var bottomButton: ButtonViewModel?
}

class VerificationView: FEView<VerificationConfiguration, VerificationViewModel> {
    
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.medium.rawValue
        return view
    }()
    
    private lazy var headerStack: UIStackView = {
        let view = UIStackView()
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
    
    private lazy var headerInfoButton: FEButton = {
        let view = FEButton()
        return view
    }()
    
    private lazy var descriptionStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = Margins.small.rawValue
        
        return stack
    }()
    
    private lazy var statusImageView: WrapperView<FEImageView> = {
        let view = WrapperView<FEImageView>()
        view.wrappedView.setup(with: .init(.imageName("CircleCheckSolid")))
        view.tintColor = LightColors.primary
        return view
    }()
    
    private lazy var descriptionLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var arrowImageView: WrapperView<FEImageView> = {
        let view = WrapperView<FEImageView>()
        view.wrappedView.setup(with: .init(.imageName("forward")))
        return view
    }()
    
    private lazy var button: FEButton = {
        let view = FEButton()
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
        }
        content.setupCustomMargins(all: .large)
        
        mainStack.addArrangedSubview(headerStack)
        headerStack.addArrangedSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().priority(.low)
            make.height.equalTo(40)
        }
        
        headerStack.addArrangedSubview(statusView)
        statusView.setupCustomMargins(vertical: .extraSmall, horizontal: .large)
        
        headerStack.addArrangedSubview(headerInfoButton)
        headerInfoButton.snp.makeConstraints { make in
            make.width.equalTo(headerInfoButton.snp.height)
        }
        
        mainStack.addArrangedSubview(descriptionStackView)
        descriptionStackView.addArrangedSubview(statusImageView)
        descriptionStackView.addArrangedSubview(descriptionLabel)
        descriptionStackView.addArrangedSubview(arrowImageView)
        descriptionLabel.snp.makeConstraints { make in
            make.height.equalTo(Margins.extraLarge.rawValue)
        }
        
        mainStack.addArrangedSubview(button)
        button.snp.makeConstraints { make in
            make.height.equalTo(Margins.extraHuge.rawValue)
        }
        setupClearMargins()
    }
    
    override func configure(with config: VerificationConfiguration?) {
        configure(background: config?.background)
        headerLabel.configure(with: config?.title)
        headerInfoButton.configure(with: config?.infoButton)
        statusView.setup { view in
            view.configure(with: config?.status?.title)
        }
        statusView.configure(background: config?.status?.background)

        descriptionLabel.configure(with: config?.description)
        button.configure(with: config?.bottomButton)
    }
    
    override func setup(with viewModel: VerificationViewModel?) {
        headerLabel.setup(with: viewModel?.title)
        headerInfoButton.setup(with: viewModel?.infoButton)
        headerInfoButton.isHidden = viewModel?.infoButton == nil
        statusImageView.isHidden = viewModel?.infoButton != nil
        arrowImageView.isHidden = viewModel?.infoButton != nil
//        statusView.setup(with: viewModel?.status)
        statusView.setup { view in
            let title = viewModel?.status.rawValue.uppercased()
            view.setup(with: .text(title))
        }
        statusView.isHidden = viewModel?.status == VerificationStatus.none
        
        descriptionLabel.setup(with: viewModel?.description)
        descriptionLabel.isHidden = viewModel?.description == nil
        button.setup(with: viewModel?.bottomButton)
        button.isHidden = viewModel?.bottomButton == nil
    }
}
