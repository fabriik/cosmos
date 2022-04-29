//
//  HomeScreenCell.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-11-28.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

protocol HighlightableCell {
    func highlight()
    func unhighlight()
}

enum HomeScreenCellIds: String {
    case regularCell        = "CurrencyCell"
    case highlightableCell  = "HighlightableCurrencyCell"
}

class Background: UIView, GradientDrawable {

    var currency: Currency?

    override func layoutSubviews() {
        super.layoutSubviews()
        let maskLayer = CAShapeLayer()
        let corners: UIRectCorner = .allCorners
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: C.Sizes.homeCellCornerRadius,
                                                          height: C.Sizes.homeCellCornerRadius)).cgPath
        layer.mask = maskLayer
    }

    override func draw(_ rect: CGRect) {
        guard let currency = currency else { return }
        let colors = currency.isSupported ? (.white, .white) : (UIColor.disabledCellBackground, UIColor.disabledCellBackground)
        drawGradient(start: colors.0, end: colors.1, rect)
    }
}

class HomeScreenCell: UITableViewCell, Subscriber {
    
    private let iconContainer = UIView(color: .transparentIconBackground)
    private let icon = UIImageView()
    private let currencyName = UILabel(font: Theme.body1Accent, color: Theme.primaryText)
    private let price = UILabel(font: Theme.body3, color: Theme.secondaryText)
    private let fiatBalance = UILabel(font: Theme.body1Accent, color: Theme.primaryText)
    private let tokenBalance = UILabel(font: Theme.body3, color: Theme.secondaryText)
    private let syncIndicator = SyncingIndicator(style: .home)
    private let priceChangeView = PriceChangeView(style: .percentOnly)
    private let cardView = UIView()
    
    let container = Background()    // not private for inheritance
        
    private var isSyncIndicatorVisible: Bool = false {
        didSet {
            UIView.crossfade(tokenBalance, syncIndicator, toRight: isSyncIndicatorVisible, duration: isSyncIndicatorVisible == oldValue ? 0.0 : 0.3)
            fiatBalance.textColor = (isSyncIndicatorVisible || !(container.currency?.isSupported ?? false)) ? .transparentBlack : .black
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    static func cellIdentifier() -> String {
        return "CurrencyCell"
    }
    
    func set(viewModel: HomeScreenAssetViewModel) {
        accessibilityIdentifier = viewModel.currency.name
        container.currency = viewModel.currency
        icon.image = viewModel.currency.imageSquareBackground
        icon.tintColor = viewModel.currency.isSupported ? .white : .disabledBackground
        iconContainer.layer.cornerRadius = C.Sizes.homeCellCornerRadius
        currencyName.text = viewModel.currency.name
        currencyName.textColor = viewModel.currency.isSupported ? .black : .transparentBlack
        price.text = viewModel.exchangeRate
        fiatBalance.text = viewModel.fiatBalance
        fiatBalance.textColor = viewModel.currency.isSupported ? .black : .transparentBlack
        tokenBalance.text = viewModel.tokenBalance
        priceChangeView.isHidden = false
        priceChangeView.currency = viewModel.currency
        container.setNeedsDisplay()
        Store.subscribe(self, selector: { $0[viewModel.currency]?.syncState != $1[viewModel.currency]?.syncState },
                        callback: { state in
                            if viewModel.currency.isHBAR && (Store.state.requiresCreation(viewModel.currency)) {
                                self.isSyncIndicatorVisible = false
                                return
                            }
                            guard let syncState = state[viewModel.currency]?.syncState else { return }
                            self.syncIndicator.syncState = syncState
                            switch syncState {
                            case .connecting, .failed, .syncing:
                                self.isSyncIndicatorVisible = true
                            case .success:
                                self.isSyncIndicatorVisible = false
                            }
        })
        
        Store.subscribe(self, selector: { $0[viewModel.currency]?.syncProgress != $1[viewModel.currency]?.syncProgress },
                        callback: { state in
                            if let progress = state[viewModel.currency]?.syncProgress {
                                self.syncIndicator.progress = progress
                            }
        })
    }
    
    func setupViews() {
        addSubviews()
        addConstraints()
        setupStyle()
    }

    private func addSubviews() {
        backgroundColor = .homeBackground
        
        contentView.addSubview(container)
        container.addSubview(cardView)
        cardView.addSubview(iconContainer)
        iconContainer.addSubview(icon)
        cardView.addSubview(currencyName)
        cardView.addSubview(price)
        cardView.addSubview(fiatBalance)
        cardView.addSubview(tokenBalance)
        cardView.addSubview(syncIndicator)
        cardView.addSubview(priceChangeView)
        syncIndicator.isHidden = true
    }

    private func addConstraints() {
        let containerPadding = C.padding[1]
        container.constrain(toSuperviewEdges: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        cardView.constrain([
            cardView.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            cardView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            cardView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: containerPadding),
            cardView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -containerPadding)])
            
        iconContainer.constrain([
            iconContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: containerPadding),
            iconContainer.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            iconContainer.widthAnchor.constraint(equalTo: iconContainer.heightAnchor)])
        icon.constrain(toSuperviewEdges: .zero)
        currencyName.constrain([
            currencyName.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: containerPadding),
            currencyName.bottomAnchor.constraint(equalTo: icon.centerYAnchor, constant: 0.0)])
        price.constrain([
            price.leadingAnchor.constraint(equalTo: currencyName.leadingAnchor),
            price.topAnchor.constraint(equalTo: currencyName.bottomAnchor)])
        priceChangeView.constrain([
            priceChangeView.leadingAnchor.constraint(equalTo: price.trailingAnchor),
            priceChangeView.centerYAnchor.constraint(equalTo: price.centerYAnchor),
            priceChangeView.heightAnchor.constraint(equalToConstant: 24)])
        fiatBalance.constrain([
            fiatBalance.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -containerPadding),
            fiatBalance.leadingAnchor.constraint(greaterThanOrEqualTo: currencyName.trailingAnchor, constant: C.padding[1]),
            fiatBalance.topAnchor.constraint(equalTo: currencyName.topAnchor)])
        tokenBalance.constrain([
            tokenBalance.trailingAnchor.constraint(equalTo: fiatBalance.trailingAnchor),
            tokenBalance.leadingAnchor.constraint(greaterThanOrEqualTo: priceChangeView.trailingAnchor, constant: C.padding[1]),
            tokenBalance.bottomAnchor.constraint(equalTo: price.bottomAnchor)])
        tokenBalance.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        fiatBalance.setContentCompressionResistancePriority(.required, for: .vertical)
        fiatBalance.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        syncIndicator.constrain([
            syncIndicator.trailingAnchor.constraint(equalTo: fiatBalance.trailingAnchor),
            syncIndicator.leadingAnchor.constraint(greaterThanOrEqualTo: priceChangeView.trailingAnchor, constant: C.padding[1]),
            syncIndicator.bottomAnchor.constraint(equalTo: tokenBalance.bottomAnchor, constant: 0.0)])
        syncIndicator.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        layoutIfNeeded()
    }

    private func setupStyle() {
        selectionStyle = .none
        
        cardView.layer.cornerRadius = C.Sizes.homeCellCornerRadius
        cardView.layer.borderColor = UIColor.shadowColor.cgColor
        cardView.layer.borderWidth = 0.5
        
        cardView.layer.shadowRadius = C.Sizes.homeCellCornerRadius
        cardView.layer.shadowColor = UIColor.shadowColor.cgColor
        cardView.layer.shadowOpacity = 2
        cardView.layer.shadowOffset = .zero
        cardView.backgroundColor = .whiteBackground
        
        iconContainer.layer.cornerRadius = C.Sizes.homeCellCornerRadius
        iconContainer.clipsToBounds = true
        icon.tintColor = .white
    }
    
    override func prepareForReuse() {
        Store.unsubscribe(self)
    }
    
    deinit {
        Store.unsubscribe(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
