// 
//  FETimerView.swift
//  breadwallet
//
//  Created by Rok on 05/07/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Presets {
    struct Timer {
        static var one = TimerConfiguration(background: .init(tintColor: LightColors.primary), font: Fonts.Body.two)
    }
}

struct TimerConfiguration: Configurable {
    var background: BackgroundConfiguration = .init(backgroundColor: .clear, tintColor: LightColors.primary)
    var font = Fonts.Body.two
}

struct TimerViewModel: ViewModel {
    var duration: Double = 15
    var image = ImageViewModel.imageName("timelapse")
    var repeats = true
    var finished: (() -> Void)?
}

class FETimerView: FEView<TimerConfiguration, TimerViewModel> {
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.spacing = Margins.minimum.rawValue
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        view.setup(with: .text("00:00s"))
        return view
    }()
    
    private lazy var iconView: FEImageView = {
        let view = FEImageView()
        return view
    }()
    
    private var timer: Timer?
    private var triggerDate: Date?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
            make.height.equalTo(ViewSizes.extraSmall.rawValue)
        }
        
        let spacer = UIView()
        stack.addArrangedSubview(spacer)
        spacer.snp.makeConstraints { make in
            make.width.equalToSuperview().priority(.low)
        }
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(iconView)
        
        let spacer2 = UIView()
        stack.addArrangedSubview(spacer2)
        spacer2.snp.makeConstraints { make in
            make.width.equalTo(spacer)
        }
    }
    
    override func configure(with config: TimerConfiguration?) {
        guard let config = config else { return }
        super.configure(with: config)
        
        configure(background: config.background)
        titleLabel.configure(with: .init(font: config.font, textColor: config.background.tintColor))
        iconView.configure(with: config.background)
    }
    
    override func setup(with viewModel: TimerViewModel?) {
        guard let viewModel = viewModel else { return }
        super.setup(with: viewModel)
        triggerDate = Date().advanced(by: viewModel.duration)
        // TODO: replace with animation
        iconView.setup(with: viewModel.image)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTime() {
        guard let triggerDate = triggerDate else { return }
        
        let components = Calendar.current.dateComponents([.minute, .second], from: Date(), to: triggerDate)

        guard let minutes = components.minute,
              let seconds = components.second else {
            return
        }
        titleLabel.text = String(format: "%02d:%02ds", minutes, seconds)
        
        guard seconds == 0, minutes == 0 else { return }
        
        timer?.invalidate()
        viewModel?.finished?()
        
        guard viewModel?.repeats == true else { return }
        setup(with: viewModel)
    }
}
