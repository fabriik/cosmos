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

enum Kyc2: String, Equatable {
    case notStarted = "KYC2_NOT_STARTED"
    case expired = "KYC2_EXPIRED"
    case submitted = "KYC2_SUBMITTED"
    case levelTwo = "KYC2"
    case resubmit = "KYC2_RESUBMISSION_REQUESTED"
    case declined = "KYC2_DECLINED"
}

enum VerificationStatus: Equatable {
    case none
    case emailPending
    case email
    case levelOne
    case levelTwo(Kyc2)
    
    var canBuyTrade: Bool {
        switch self {
        case .levelOne,
                .levelTwo:
            return true
            
        default:
            return false
        }
    }
    
    var value: String {
        switch self {
        case .none: return "DEFAULT"
        case .emailPending: return "EMAIL_VERIFICATION_PENDING"
        case .email: return "EMAIL_VERIFIED"
        case .levelOne: return "KYC1"
        case .levelTwo(let kyc2): return kyc2.rawValue
        }
    }

    init(rawValue: String?) {
        switch rawValue?.uppercased() {
        case "DEFAULT": self = .none
        case "EMAIL_VERIFICATION_PENDING": self = .emailPending
        case "EMAIL_VERIFIED": self = .email
        case "KYC1": self = .levelOne
            
        default:
            let kyc2 = Kyc2.init(rawValue: rawValue?.uppercased() ?? "")
            if let kyc2 = kyc2 {
                self = .levelTwo(kyc2)
            } else {
                self = .none
            }
        }
    }
    
    var title: String {
        switch self {
        case .email, .levelOne, .levelTwo(.levelTwo): return "Verified"
        case .levelTwo(.declined): return "Declined"
        case .levelTwo(.resubmit), .levelTwo(.expired): return "Resubmit"
        default: return "Pending"
        }
    }
#if swift(>=4.1)
#else
    static func >(lhs: VerificationStatus, rhs: VerificationStatus) -> Bool {
        switch (lhs, rhs) {
        case (.levelTwo(let lhs1), .levelTwo(let lhs2)):
            return lhs1 == lhs2
        default:
            return false
        }
    }
#endif
}

struct StatusViewConfiguration: Configurable {
    var title: LabelConfiguration?
    var background: BackgroundConfiguration?
}

struct VerificationConfiguration: Configurable {
    var shadow: ShadowConfiguration?
    var background: BackgroundConfiguration?
    var title: LabelConfiguration?
    // TODO: custom
    var status: StatusViewConfiguration?
    var infoButton: ButtonConfiguration?
    var description: LabelConfiguration?
    var benefits: LabelConfiguration?
}

enum KYC {
    case levelOne
    case levelTwo
}

struct VerificationViewModel: ViewModel {
    var kyc: KYC
    var title: LabelViewModel?
    // TODO: custom
    var status: VerificationStatus
    var infoButton: ButtonViewModel?
    var description: LabelViewModel?
    var benefits: LabelViewModel?
    var isActive: Bool?
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
        view.tintColor = LightColors.Icons.two
        return view
    }()
    
    private lazy var benefitsLabel: WrapperView<FELabel>  = {
        let view = WrapperView<FELabel>()
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
        statusView.setupCustomMargins(all: .small)
        statusView.content.setupCustomMargins(vertical: .zero, horizontal: .small)
        
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
        
        mainStack.addArrangedSubview(benefitsLabel)
        benefitsLabel.snp.makeConstraints { make in
            make.height.equalTo(Margins.huge.rawValue)
            make.width.equalToSuperview().inset(Margins.small.rawValue)
        }
        setupClearMargins()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configure(background: config?.background)
        configure(shadow: config?.shadow)
    }
    
    override func configure(with config: VerificationConfiguration?) {
        guard let config = config else { return }
        
        super.configure(with: config)
        
        configure(background: config.background)
        configure(shadow: config.shadow)
        
        headerLabel.configure(with: config.title)
        headerInfoButton.configure(with: config.infoButton)
        
        statusView.wrappedView.configure(with: config.status?.title)
        statusView.configure(background: config.status?.background)

        descriptionLabel.configure(with: config.description)
        benefitsLabel.wrappedView.configure(with: config.benefits)
    }
    
    override func setup(with viewModel: VerificationViewModel?) {
        guard let viewModel = viewModel else { return }

        super.setup(with: viewModel)
        
        headerLabel.setup(with: viewModel.title)
        headerInfoButton.setup(with: viewModel.infoButton)
        headerInfoButton.isHidden = viewModel.infoButton == nil
        statusImageView.isHidden = viewModel.infoButton != nil
        arrowImageView.isHidden = viewModel.infoButton != nil
        statusView.wrappedView.setup(with: .text(viewModel.status.title))
        statusView.isHidden = viewModel.status == VerificationStatus.none
        // if level 1 was done, but we present level 2, status is hidden
        if viewModel.status == .levelOne,
           viewModel.kyc == .levelTwo {
            statusView.isHidden = true
        }
        descriptionLabel.setup(with: viewModel.description)
        descriptionLabel.isHidden = viewModel.description == nil
        
        benefitsLabel.wrappedView.setup(with: viewModel.benefits)
        benefitsLabel.isHidden = viewModel.benefits == nil
        if viewModel.isActive ?? true {
            benefitsLabel.configure(background: Presets.Background.Primary.normal.withBorder(border: Presets.Border.normal))
        } else {
            benefitsLabel.configure(background: Presets.Background.Primary.disabled.withBorder(border: Presets.Border.normal))
            statusImageView.tintColor = LightColors.Contrast.two
        }
    }
}
