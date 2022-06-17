//
//  NameView.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import UIKit

struct NameViewConfiguration: Configurable {
    
}

struct NameViewModel: ViewModel {
    var title: LabelViewModel?
    var firstName: TextFieldModel?
    var lastName: TextFieldModel?
}

class NameView: FEView<NameViewConfiguration, NameViewModel> {
    
    var contentSizeChanged: (() -> Void)?
    var valueChanged: ((_ first: String?, _ last: String?) -> Void)?
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.extraSmall.rawValue
        return view
    }()
    
    private lazy var nameStack: UIStackView = {
        let view = UIStackView()
        view.spacing = Margins.small.rawValue
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var lastNameTextfield: FETextField = {
        let view = FETextField()
        return view
    }()
    
    private lazy var firstNameTextField: FETextField = {
        let view = FETextField()
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
        }
        
        stack.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            // TODO: constant
            make.height.equalTo(20)
        }
        
        stack.addArrangedSubview(nameStack)
        nameStack.addArrangedSubview(firstNameTextField)
        nameStack.addArrangedSubview(lastNameTextfield)
        
        nameStack.arrangedSubviews.forEach { arrangedSubview in
            arrangedSubview.snp.makeConstraints { make in
                make.height.equalTo(FieldHeights.common.rawValue)
            }
        }
    }
    
    override func configure(with config: NameViewConfiguration?) {
        super.configure(with: config)
        
        titleLabel.configure(with: .init(font: Fonts.Body.two, textColor: LightColors.Text.two))
        firstNameTextField.configure(with: Presets.TextField.primary)
        lastNameTextfield.configure(with: Presets.TextField.primary)
    }
    
    override func setup(with viewModel: NameViewModel?) {
        super.setup(with: viewModel)
        
        titleLabel.setup(with: viewModel?.title)
        firstNameTextField.setup(with: viewModel?.firstName)
        lastNameTextfield.setup(with: viewModel?.lastName)
        
        firstNameTextField.valueChanged = { [weak self] in
            self?.stateChanged(firstName: $0)
        }
        
        lastNameTextfield.valueChanged = { [weak self] in
            self?.stateChanged(lastName: $0)
        }
        stack.layoutIfNeeded()
    }
    
    var firstName: String?
    var lastName: String?
    
    private func stateChanged(firstName: String? = nil, lastName: String? = nil) {
        // TODO: clean up this logic
        if let first = firstName {
            self.firstName = first.isEmpty ? nil : first
        } else if let last = lastName {
            self.lastName = last.isEmpty ? nil : last
        }
        valueChanged?(self.firstName, self.lastName)
        
        Self.animate(withDuration: Presets.Animation.duration) { [weak self] in
            self?.content.layoutIfNeeded()
            self?.contentSizeChanged?()
        }
    }
}
