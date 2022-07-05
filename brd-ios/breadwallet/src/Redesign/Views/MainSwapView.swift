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
