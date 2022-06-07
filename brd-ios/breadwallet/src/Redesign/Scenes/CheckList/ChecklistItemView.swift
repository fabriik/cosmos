// 
//  ChecklistItemView.swift
//  breadwallet
//
//  Created by Rok on 07/06/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct ChecklistItemConfiguration: Configurable {
    var title: LabelConfiguration? = .init(font: Fonts.Body.two, textColor: LightColors.Text.two)
    var image: BackgroundConfiguration? = .init(backgroundColor: .clear, tintColor: LightColors.primary)
}

struct ChecklistItemViewModel: ViewModel {
    var title: LabelViewModel?
    var image: ImageViewModel = .imageName("check")
}

class ChecklistItemView: FEView<ChecklistItemConfiguration, ChecklistItemViewModel> {
    
    private lazy var checkmarImageView: FEImageView = {
        let view = FEImageView()
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        content.addSubview(checkmarImageView)
        checkmarImageView.snp.makeConstraints { make in
            make.top.equalTo(content.snp.topMargin)
            make.leading.equalTo(content.snp.leadingMargin)
            make.height.equalTo(checkmarImageView.snp.width)
            make.width.equalTo(Margins.extraLarge.rawValue)
        }
        
        content.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkmarImageView.snp.trailing).offset(Margins.medium.rawValue)
            make.trailing.equalTo(content.snp.trailingMargin)
            make.top.equalTo(content.snp.topMargin)
            make.bottom.equalTo(content.snp.bottomMargin)
        }
    }
    
    override func configure(with config: ChecklistItemConfiguration?) {
        super.configure(with: config)
        checkmarImageView.configure(with: config?.image)
        titleLabel.configure(with: config?.title)
    }
    
    override func setup(with viewModel: ChecklistItemViewModel?) {
        super.setup(with: viewModel)
        checkmarImageView.setup(with: viewModel?.image)
        titleLabel.setup(with: viewModel?.title)
    }
}
