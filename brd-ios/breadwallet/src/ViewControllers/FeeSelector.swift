//
//  FeeSelector.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-07-20.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

//TODO:CRYPTO_V2 - these should come from BlockchainDB eventually
enum FeeLevel: Int {
    case economy
    case regular
    case priority
    
    //Time in millis
    func preferredTime(forCurrency currency: Currency) -> Int {
        
        if currency.uid == Currencies.shared.btc?.uid {
            switch self {
            case .economy:
                return Int(C.secondsInMinute) * 60 * 7 * 1000 //7 hrs
            case .regular:
                return Int(C.secondsInMinute) * 30 * 1000 //30 mins
            case .priority:
                return Int(C.secondsInMinute) * 10 * 1000 //10 mins
            }
        }
        
        if currency.isEthereumCompatible {
            switch self {
            case .economy:
                return Int(C.secondsInMinute) * 5 * 1000
            case .regular:
                return Int(C.secondsInMinute) * 3 * 1000
            case .priority:
                return Int(C.secondsInMinute) * 1 * 1000
            }
        }
        
        if currency.uid == "tezos-mainnet:__native__" {
            return 60000
        }
        
        return Int(C.secondsInMinute) * 3 * 1000 // 3 mins
    }
}

class FeeSelector: UIView {

    init(currency: Currency) {
        self.currency = currency
        super.init(frame: .zero)
        setupViews()
    }

    var didUpdateFee: ((FeeLevel) -> Void)?

    private let currency: Currency
    private let topBorder = UIView(color: .secondaryShadow)
    private let header = UILabel(font: .customMedium(size: 16.0), color: .darkText)
    private let subheader = UILabel(font: .customBody(size: 14.0), color: .grayTextTint)
    private let warning = UILabel.wrapping(font: .customBody(size: 14.0), color: .red)
    private let control = UISegmentedControl(items: [S.FeeSelector.economy, S.FeeSelector.regular, S.FeeSelector.priority])

    private func setupViews() {
        addSubview(topBorder)
        addSubview(control)
        addSubview(header)
        addSubview(subheader)
        addSubview(warning)

        topBorder.constrainTopCorners(height: 1.0)
        header.constrain([
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: C.padding[2]),
            header.topAnchor.constraint(equalTo: topBorder.bottomAnchor, constant: C.padding[1]) ])
        subheader.constrain([
            subheader.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            subheader.topAnchor.constraint(equalTo: header.bottomAnchor) ])

        warning.constrain([
            warning.leadingAnchor.constraint(equalTo: subheader.leadingAnchor),
            warning.topAnchor.constraint(equalTo: control.bottomAnchor, constant: 4.0),
            warning.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[2]),
            warning.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -C.padding[1])])
        header.text = S.FeeSelector.title
        subheader.text = currency.feeText(forIndex: 1)
        control.constrain([
            control.leadingAnchor.constraint(equalTo: warning.leadingAnchor),
            control.topAnchor.constraint(equalTo: subheader.bottomAnchor, constant: 4.0),
            control.widthAnchor.constraint(equalTo: widthAnchor, constant: -C.padding[4]) ])
        control.valueChanged = strongify(self) { myself in
            let fee: FeeLevel
            let subheader: String
            let warning: String
            switch myself.control.selectedSegmentIndex {
            case 1:
                fee = .regular
                subheader = self.currency.feeText(forIndex: 1)
                warning = ""
            case 2:
                fee = .priority
                subheader = self.currency.feeText(forIndex: 2)
                warning = ""
            default:
                fee = .economy
                subheader = self.currency.feeText(forIndex: 0)
                warning = S.FeeSelector.economyWarning
                
            }
            myself.didUpdateFee?(fee)
            myself.subheader.text = subheader
            myself.warning.text = warning
        }

        control.selectedSegmentIndex = 1
        control.tintColor = .primaryButton
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
