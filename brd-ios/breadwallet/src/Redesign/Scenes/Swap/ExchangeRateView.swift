// 
//  ExchangeRateView.swift
//  breadwallet
//
//  Created by Rok on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct ExchangeRadeConfiguration: Configurable {
    var title = LabelConfiguration(font: Fonts.Subtitle.two, textColor: LightColors.Text.one)
    var value = LabelConfiguration(font: Fonts.Body.two, textColor: LightColors.Text.one)
    var background = BackgroundConfiguration()
    var timer = Presets.Timer.one
}

struct ExchamgeRateViewModel: ViewModel {
    var firstCurrency: String
    var secondCurrency: String
    var exchangeRate: Double
    var timer = TimerViewModel(duration: 15, image: .imageName("timelapse"), repeats: true)
}

class ExchangeRateView: FEView<ExchangeRadeConfiguration, ExchamgeRateViewModel> {
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        // TODO: localize
        view.setup(with: .text("Rate"))
        return view
    }()
    
    private lazy var valueLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var timerView: FETimerView = {
        let view = FETimerView()
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        content.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(content.snp.leadingMargin)
            make.centerY.equalToSuperview()
        }
        
        content.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(Margins.small.rawValue)
            make.centerY.equalToSuperview()
        }
        
        content.addSubview(timerView)
        timerView.snp.makeConstraints { make in
            make.trailing.equalTo(content.snp.trailingMargin)
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(valueLabel.snp.trailing)
        }
    }
    
    override func configure(with config: ExchangeRadeConfiguration?) {
        guard let config = config else { return }
        super.configure(with: config)
        
        configure(background: config.background)
        titleLabel.configure(with: config.title)
        valueLabel.configure(with: config.value)
        timerView.configure(with: config.timer)
    }
    
    override func setup(with viewModel: ExchamgeRateViewModel?) {
        guard let viewModel = viewModel else { return }

        super.setup(with: viewModel)
        valueLabel.text = "1 \(viewModel.firstCurrency) = \(viewModel.exchangeRate) \(viewModel.secondCurrency)"
        timerView.setup(with: viewModel.timer)
    }
}
