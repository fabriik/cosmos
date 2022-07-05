// 
//  MainSwapView.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import SnapKit

struct MainSwapConfiguration: Configurable {
    var shadow: ShadowConfiguration?
    var background: BackgroundConfiguration?
}

struct MainSwapViewModel: ViewModel {
    var fromFiatAmount: String
    var fromCryptoAmount: String
    var toFiatAmount: String
    var toCryptoAmount: String
}

class SwapCurrencyView: UIView, UITextFieldDelegate {
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

class MainSwapView: FEView<MainSwapConfiguration, MainSwapViewModel> {
    private lazy var containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        return stack
    }()
    
    private var topSwapCurrencyView = SwapCurrencyView()
    private var bottomSwapCurrencyView = SwapCurrencyView()
    
    private lazy var dividerWithButtonView: UIView = {
        let view = UIView()
        
        let lineView = UIView()
        lineView.backgroundColor = LightColors.Outline.two
        
        view.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.height.width.equalTo(1)
            make.leading.trailing.equalToSuperview()
            make.center.equalToSuperview()
        }
        
        let buttonView = FEButton()
        buttonView.setImage(UIImage(named: "SwitchPlaces"), for: .normal)
        buttonView.addTarget(self, action: #selector(switchPlacesButtonTapped), for: .touchUpInside)
        
        view.addSubview(buttonView)
        buttonView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return view
    }()
    
    var switchPlacesButtonCallback: (() -> Void)?
    var didChangeFromFiatAmount: ((SwapMainModels.Amounts.CurrencyData?) -> Void)?
    var didChangeFromCryptoAmount: ((SwapMainModels.Amounts.CurrencyData?) -> Void)?
    var didChangeToFiatAmount: ((SwapMainModels.Amounts.CurrencyData?) -> Void)?
    var didChangeToCryptoAmount: ((SwapMainModels.Amounts.CurrencyData?) -> Void)?
    
    private var subviewOrder: Int = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configure(background: config?.background)
        configure(shadow: config?.shadow)
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(containerStackView)
        containerStackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        containerStackView.addArrangedSubview(topSwapCurrencyView)
        containerStackView.addArrangedSubview(dividerWithButtonView)
        containerStackView.addArrangedSubview(bottomSwapCurrencyView)
        
        dividerWithButtonView.snp.makeConstraints { make in
            make.height.equalTo(32)
        }
        
        topSwapCurrencyView.currencySelectorStackView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                                  action: #selector(topCurrencyTapped(_:))))
        bottomSwapCurrencyView.currencySelectorStackView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                                                     action: #selector(bottomCurrencyTapped(_:))))
        
        getAmounts()
    }
    
    private func getAmounts() {
        (containerStackView.arrangedSubviews.first(where: { $0 is SwapCurrencyView }) as? SwapCurrencyView)?.didChangeFiatAmount = { [weak self] amount in
            self?.didChangeFromFiatAmount?(amount)
        }
        
        (containerStackView.arrangedSubviews.first(where: { $0 is SwapCurrencyView }) as? SwapCurrencyView)?.didChangeCryptoAmount = { [weak self] amount in
            self?.didChangeFromCryptoAmount?(amount)
        }
        
        (containerStackView.arrangedSubviews.last(where: { $0 is SwapCurrencyView }) as? SwapCurrencyView)?.didChangeFiatAmount = { [weak self] amount in
            self?.didChangeToFiatAmount?(amount)
        }
        
        (containerStackView.arrangedSubviews.last(where: { $0 is SwapCurrencyView }) as? SwapCurrencyView)?.didChangeCryptoAmount = { [weak self] amount in
            self?.didChangeToCryptoAmount?(amount)
        }
    }
    
    override func configure(with config: MainSwapConfiguration?) {
        guard let config = config else { return }
        super.configure(with: config)
        
        configure(shadow: config.shadow)
    }
    
    override func setup(with viewModel: MainSwapViewModel?) {
        guard let viewModel = viewModel else { return }
        super.setup(with: viewModel)
        
    }
    
    private func updateAlpha(value: CGFloat) {
        topSwapCurrencyView.iHaveLabel.alpha = value
        topSwapCurrencyView.fiatTitleStackView.alpha = value
        topSwapCurrencyView.fiatAmountField.alpha = value
        topSwapCurrencyView.fiatCurrencySignLabel.alpha = value
        topSwapCurrencyView.currencyAmountTitleLabel.alpha = value
        topSwapCurrencyView.feeLabel.alpha = value
        topSwapCurrencyView.fromToConversionLabel.alpha = value
        
        bottomSwapCurrencyView.iHaveLabel.alpha = value
        bottomSwapCurrencyView.fiatTitleStackView.alpha = value
        bottomSwapCurrencyView.fiatAmountField.alpha = value
        bottomSwapCurrencyView.fiatCurrencySignLabel.alpha = value
        bottomSwapCurrencyView.currencyAmountTitleLabel.alpha = value
        bottomSwapCurrencyView.feeLabel.alpha = value
        bottomSwapCurrencyView.fromToConversionLabel.alpha = value
    }
    
    // MARK: - User interaction
    
    @objc private func topCurrencyTapped(_ sender: Any?) {
        
    }
    
    @objc private func bottomCurrencyTapped(_ sender: Any?) {
        
    }
    
    @objc private func switchPlacesButtonTapped(_ sender: UIButton?) {
        UIView.animate(withDuration: Presets.Animation.duration * 3,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 3,
                       options: .curveEaseInOut) { [weak self] in
            sender?.isEnabled = false
            sender?.transform = sender?.transform == .identity ? CGAffineTransform(rotationAngle: .pi) : .identity
            
            let topFrame = self?.topSwapCurrencyView.currencySelectorStackView ?? UIView()
            let bottomFrame = self?.bottomSwapCurrencyView.currencySelectorStackView ?? UIView()
            let frame = topFrame.convert(topFrame.bounds, from: bottomFrame)
            let verticalDistance = frame.minY - topFrame.bounds.maxY + topFrame.frame.height
            
            self?.topSwapCurrencyView.currencySelectorStackView.transform = self?.topSwapCurrencyView.currencySelectorStackView.transform == .identity
            ? .init(translationX: 0, y: verticalDistance) : .identity
            self?.bottomSwapCurrencyView.currencySelectorStackView.transform = self?.bottomSwapCurrencyView.currencySelectorStackView.transform == .identity
            ? .init(translationX: 0, y: -verticalDistance) : .identity
        } completion: { _ in
            
        }
        
        UIView.animate(withDuration: Presets.Animation.duration, delay: Presets.Animation.duration, options: []) { [weak self] in
            self?.updateAlpha(value: 0.2)
        } completion: { [weak self] _ in
            self?.topSwapCurrencyView.currencySelectorStackView.transform = .identity
            self?.bottomSwapCurrencyView.currencySelectorStackView.transform = .identity
            
            self?.containerStackView.addArrangedSubview(self?.containerStackView.subviews[self?.subviewOrder ?? 0] ?? UIView())
            self?.containerStackView.insertArrangedSubview(self?.dividerWithButtonView ?? UIView(), at: 1)
            
            self?.subviewOrder = self?.subviewOrder == 0 ? 2 : 0
            
            UIView.animate(withDuration: Presets.Animation.duration) { [weak self] in
                self?.updateAlpha(value: 1)
                
                sender?.isEnabled = true
                
                self?.getAmounts()
            }
        }
        
        switchPlacesButtonCallback?()
    }
}
