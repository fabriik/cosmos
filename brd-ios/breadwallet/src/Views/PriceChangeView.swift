//
//  PriceChangeView.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2019-04-01.
//  Copyright © 2019 breadwallet LLC. All rights reserved.
//

import UIKit

enum PriceChangeViewStyle {
    case percentOnly
    case percentAndAbsolute
}

class PriceChangeView: UIView, Subscriber {
    
    var currency: Currency? = nil {
        didSet {
            //These cells get recycled, so we need to cancel any previous subscriptions
            Store.unsubscribe(self)
            setInitialData()
            subscribeToPriceChange()
        }
    }
    
    private let percentLabel = UILabel(font: Theme.body3)
    private let absoluteLabel = UILabel(font: Theme.body3)
    private let plusLabel = UILabel(font: Theme.body3)
    private let separator = UIView(color: .greenCheck)
    
    private var priceInfo: FiatPriceInfo? {
        didSet {
            handlePriceChange()
        }
    }
    
    private var currencyNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = Rate.symbolMap[Store.state.defaultCurrencyCode]
        return formatter
    }
    
    private let style: PriceChangeViewStyle
    
    init(style: PriceChangeViewStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }
    
    private func setup() {
        addSubviews()
        setupConstraints()
        setInitialData()
    }
    
    private func setupConstraints() {
        separator.constrain([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.half),
            separator.topAnchor.constraint(equalTo: topAnchor, constant: 4.0),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.0),
            separator.widthAnchor.constraint(equalToConstant: 1.0)])
        plusLabel.constrain([
            plusLabel.leadingAnchor.constraint(equalTo: separator.trailingAnchor, constant: Padding.half),
            plusLabel.centerYAnchor.constraint(equalTo: centerYAnchor)])
        percentLabel.constrain([
            percentLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            percentLabel.leadingAnchor.constraint(equalTo: plusLabel.trailingAnchor, constant: 3.0)])
        absoluteLabel.constrain([
            absoluteLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            absoluteLabel.leadingAnchor.constraint(equalTo: percentLabel.trailingAnchor, constant: C.padding[1]/2.0),
            absoluteLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[1])])
        if style == .percentOnly {
            percentLabel.constrain([
                percentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4.0)])
        }
    }
    
    private func addSubviews() {
        addSubview(separator)
        addSubview(percentLabel)
        addSubview(plusLabel)
        addSubview(absoluteLabel)
    }
    
    private func setInitialData() {
        separator.alpha = 0.0
        plusLabel.textColor = .greenCheck
        percentLabel.textColor = .greenCheck
        absoluteLabel.textColor = .greenCheck
        percentLabel.text = nil
        absoluteLabel.text = nil
    }
    
    private func handlePriceChange() {
        guard let priceChange = priceInfo else { return }
        
        //Set label text
        let percentText = String(format: "%.2f%%", fabs(priceChange.changePercentage24Hrs))
        plusLabel.text = "+"
        if style == .percentAndAbsolute, let absoluteString = currencyNumberFormatter.string(from: NSNumber(value: abs(priceChange.change24Hrs))) {
            absoluteLabel.text = "(\(absoluteString))"
            percentLabel.text = percentText
            layoutIfNeeded()
        } else if style == .percentOnly {
            percentLabel.fadeToText(percentText)
        }
    }
    
    private func subscribeToPriceChange() {
        guard let currency = currency else { return }
        Store.subscribe(self, selector: { $0[currency]?.fiatPriceInfo != $1[currency]?.fiatPriceInfo }, callback: {
            self.priceInfo = $0[currency]?.fiatPriceInfo
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension UILabel {
    
    func fadeToText(_ text: String) {
        fadeTransition(C.animationDuration)
        self.text = text
    }
    
    func fadeTransition(_ duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = .fade
        animation.duration = duration
        layer.add(animation, forKey: animation.type.rawValue)
    }
}
