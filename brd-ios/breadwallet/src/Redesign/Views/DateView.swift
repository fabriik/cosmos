// 
//  DateView.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct DateConfiguration: Configurable {
    var normal = Presets.Background.Primary.normal
    var selected = Presets.Background.Primary.selected
}

struct DateViewModel: ViewModel {
    var date: Date?
    var title: LabelViewModel? = .text("Date of birth")
    var month: TextFieldModel? = .init(title: "MONTH")
    var day: TextFieldModel? = .init(title: "DAY")
    var year: TextFieldModel? = .init(title: "YEAR")
}

class DateView: FEView<DateConfiguration, DateViewModel>, StateDisplayable {
    
    var contentSizeChanged: (() -> Void)?
    var valueChanged: ((Date?) -> Void)?
    var displayState: DisplayState = .normal
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.extraSmall.rawValue
        return view
    }()
    
    private lazy var dateStack: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = Margins.small.rawValue
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var monthTextfield: FETextField = {
        let view = FETextField()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var dayTextField: FETextField = {
        let view = FETextField()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var yearTextField: FETextField = {
        let view = FETextField()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var hiddenTextField: UITextField = {
        let view = UITextField()
        view.inputView = datePicker
        return view
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let view = UIDatePicker()
        view.datePickerMode = .date
        if #available(iOS 13.4, *) {
            view.preferredDatePickerStyle = .wheels
        } else {
            // TODO: how to handle?
            // Fallback on earlier versions
        }
        return view
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(hiddenTextField)
        hiddenTextField.alpha = 0
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
        
        stack.addArrangedSubview(dateStack)
        dateStack.addArrangedSubview(dayTextField)
        dateStack.addArrangedSubview(monthTextfield)
        dateStack.addArrangedSubview(yearTextField)
        
        dateStack.arrangedSubviews.forEach { arrangedSubview in
            (arrangedSubview as? FETextField)?.isPicker = true
        }
        
        dateStack.arrangedSubviews.forEach { arrangedSubview in
            arrangedSubview.snp.makeConstraints { make in
                make.height.equalTo(FieldHeights.common.rawValue)
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
        
        datePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func configure(with config: DateConfiguration?) {
        super.configure(with: config)
        
        titleLabel.configure(with: .init(font: Fonts.Body.two, textColor: LightColors.Text.two))
        monthTextfield.configure(with: Presets.TextField.primary)
        dayTextField.configure(with: Presets.TextField.primary)
        yearTextField.configure(with: Presets.TextField.primary)
    }
    
    override func setup(with viewModel: DateViewModel?) {
        super.setup(with: viewModel)

        titleLabel.setup(with: viewModel?.title)
        monthTextfield.setup(with: viewModel?.month)
        dayTextField.setup(with: viewModel?.day)
        yearTextField.setup(with: viewModel?.year)
        stack.layoutIfNeeded()
        
        guard let date = viewModel?.date else { return }
        datePicker.date = date
        dateChanged(datePicker: datePicker)
    }
    
    @objc private func dateChanged(datePicker: UIDatePicker) {
        let components = datePicker.calendar.dateComponents([.day, .month, .year], from: datePicker.date)
        guard let month = components.month,
              let day = components.day,
              let year = components.year
        else { return }
        valueChanged?(datePicker.date)
        monthTextfield.value = "\(month)"
        dayTextField.value = "\(day)"
        yearTextField.value = "\(year)"
    }
    
    @objc private func tapped() {
        hiddenTextField.becomeFirstResponder()
        animateTo(state: .selected)
    }
    
    @objc func keyboardWillHide() {
        animateTo(state: .normal)
    }
    
    func animateTo(state: DisplayState, withAnimation: Bool = true) {
        guard let config = config else { return }
        let background: BackgroundConfiguration?
        switch state {
        case .selected:
            background = config.selected
        default:
            background = config.normal
        }
        displayState = state
        configure(background: background)
    }
    
    override func configure(background: BackgroundConfiguration? = nil) {
        guard let border = background?.border else { return }
        
        for textField in [monthTextfield, dayTextField, yearTextField] {
            textField.layer.masksToBounds = true
            textField.layer.cornerRadius = border.cornerRadius.rawValue
            textField.layer.borderWidth = border.borderWidth
            textField.layer.borderColor = border.tintColor.cgColor
        }
    }
}
