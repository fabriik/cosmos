// 
//  SwapCurrencyView.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SwapCurrencyView: UIView {
    var didChangeFiatAmount: ((SwapMainModels.Amounts.CurrencyData?) -> Void)?
    var didChangeCryptoAmount: ((SwapMainModels.Amounts.CurrencyData?) -> Void)?
    
    private lazy var currencyContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var currencyHeaderStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .equalSpacing
        return view
    }()
    
    lazy var iHaveLabel: FELabel = {
        let view = FELabel()
        view.text = "I have 100 BSV"
        view.font = Fonts.caption
        view.textColor = LightColors.Icons.one
        view.textAlignment = .left
        return view
    }()
    
    lazy var fiatTitleStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = Margins.extraSmall.rawValue
        return view
    }()
    
    lazy var fiatAmountField: UITextField = {
        let view = UITextField()
        view.textColor = LightColors.Icons.one
        view.font = Fonts.Subtitle.two
        view.attributedPlaceholder = NSAttributedString(
            string: "0.00",
            attributes: [NSAttributedString.Key.foregroundColor: view.textColor ?? UIColor.black,
                         NSAttributedString.Key.font: view.font ?? UIFont.systemFont(ofSize: 12)]
        )
        view.tintColor = view.textColor
        view.textAlignment = .right
        view.keyboardType = .numberPad
        view.addTarget(self, action: #selector(fiatAmountDidChange(_:)), for: .editingChanged)
        
        let lineView = UIView()
        lineView.backgroundColor = LightColors.Outline.two
        
        view.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    lazy var fiatCurrencySignLabel: FELabel = {
        let view = FELabel()
        view.text = Store.state.defaultCurrencyCode
        view.font = Fonts.Subtitle.two
        view.textColor = LightColors.Icons.one
        view.textAlignment = .right
        return view
    }()
    
    lazy var currencySelectorStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = Margins.medium.rawValue
        return view
    }()
    
    private lazy var currencyIconImageView: FEImageView = {
        let view = FEImageView()
        view.setup(with: .imageName("camera-btn-pressed"))
        return view
    }()
    
    private lazy var currencyIconTitleLabel: FELabel = {
        let view = FELabel()
        view.text = Currencies.shared.currencies.randomElement()?.code.uppercased() ?? ""
        view.font = Fonts.Title.four
        view.textColor = LightColors.Icons.one
        view.textAlignment = .left
        return view
    }()
    
    private lazy var currencySelectionArrowIconView: FEImageView = {
        let view = FEImageView()
        view.setup(with: .imageName("SwapCurrencyArrow"))
        return view
    }()
    
    lazy var currencyAmountTitleLabel: UITextField = {
        let view = UITextField()
        view.textColor = LightColors.Icons.one
        view.font = Fonts.Title.four
        view.attributedPlaceholder = NSAttributedString(
            string: "0.00",
            attributes: [NSAttributedString.Key.foregroundColor: view.textColor ?? UIColor.black,
                         NSAttributedString.Key.font: view.font ?? UIFont.systemFont(ofSize: 12)]
        )
        view.tintColor = view.textColor
        view.textAlignment = .right
        view.keyboardType = .numberPad
        view.addTarget(self, action: #selector(cryptoAmountDidChange(_:)), for: .editingChanged)
        
        let lineView = UIView()
        lineView.backgroundColor = LightColors.Outline.two
        
        view.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    private lazy var feeAndAmountsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .equalSpacing
        return view
    }()
    
    lazy var feeLabel: FELabel = {
        let view = FELabel()
        view.text = "Sending network fee\n(included)"
        view.font = Fonts.caption
        view.textColor = LightColors.Text.two
        view.textAlignment = .left
        view.numberOfLines = 0
        return view
    }()
    
    lazy var fromToConversionLabel: FELabel = {
        let view = FELabel()
        view.text = "0.00023546\nBSV 0.01 USD"
        view.font = Fonts.caption
        view.textColor = LightColors.Text.two
        view.textAlignment = .right
        view.numberOfLines = 0
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(currencyContainerView)
        currencyContainerView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        currencyContainerView.addSubview(currencyHeaderStackView)
        currencyHeaderStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(Margins.large.rawValue)
        }
        
        fiatTitleStackView.addArrangedSubview(fiatAmountField)
        fiatTitleStackView.addArrangedSubview(fiatCurrencySignLabel)

        currencyHeaderStackView.addArrangedSubview(iHaveLabel)
        currencyHeaderStackView.addArrangedSubview(fiatTitleStackView)
        
        currencyContainerView.addSubview(currencySelectorStackView)
        currencySelectorStackView.snp.makeConstraints { make in
            make.top.equalTo(currencyHeaderStackView.snp.bottom).offset(Margins.medium.rawValue)
            make.leading.equalTo(currencyHeaderStackView)
            make.height.equalTo(32)
            make.width.equalTo(140)
        }
        
        currencySelectorStackView.addArrangedSubview(currencyIconImageView)
        currencyIconImageView.snp.makeConstraints { make in
            make.width.equalTo(currencySelectorStackView.snp.height)
        }
        
        currencySelectorStackView.addArrangedSubview(currencyIconTitleLabel)
        currencySelectorStackView.addArrangedSubview(currencySelectionArrowIconView)
        
        currencyContainerView.addSubview(currencyAmountTitleLabel)
        currencyAmountTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(currencySelectorStackView.snp.top)
            make.trailing.equalTo(currencyHeaderStackView)
            make.leading.lessThanOrEqualTo(currencySelectorStackView).offset(Margins.small.rawValue).priority(.low)
            make.height.equalTo(currencySelectorStackView.snp.height)
        }
        
        currencyContainerView.addSubview(feeAndAmountsStackView)
        feeAndAmountsStackView.snp.makeConstraints { make in
            make.top.equalTo(currencySelectorStackView.snp.bottom).offset(Margins.huge.rawValue)
            make.leading.trailing.equalTo(currencyHeaderStackView)
            make.bottom.equalToSuperview().inset(Margins.huge.rawValue)
        }
        
        feeAndAmountsStackView.addArrangedSubview(feeLabel)
        feeAndAmountsStackView.addArrangedSubview(fromToConversionLabel)
    }
    
    @objc func fiatAmountDidChange(_ textField: UITextField) {
        let amountString = textField.text?.currencyInputFormatting()
        textField.text = amountString?.formattedString
        
        didChangeFiatAmount?(amountString)
    }
    
    @objc func cryptoAmountDidChange(_ textField: UITextField) {
        let amountString = textField.text?.currencyInputFormatting()
        textField.text = amountString?.formattedString
        
        didChangeCryptoAmount?(amountString)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension String {
    // Should this stay? How should it work?
    func currencyInputFormatting() -> SwapMainModels.Amounts.CurrencyData? {
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumIntegerDigits = 10
        
        var amountWithPrefix = self
        
        let regex = try? NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex?.stringByReplacingMatches(in: amountWithPrefix,
                                                           options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                                           range: NSRange(location: 0,
                                                                          length: count),
                                                           withTemplate: "") ?? ""
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        return number == 0 ? nil : SwapMainModels.Amounts.CurrencyData(formattedString: formatter.string(from: number),
                                                                       number: number)
    }
}
