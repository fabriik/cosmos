// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

class KYCProgressView: BaseViewDeprecated, GenericSettable {
    typealias Model = ViewModel
    
    struct ViewModel: Hashable {
        let text: String
        let stepCount: Int
        let currentStep: Int
    }
    
    enum PersonalInformationProgress: Int, CaseIterable {
        case address
        case personalInfo
        case idFront
        case idBack
        case idSelfie
        case complete
    }
    
    enum ForgotPasswordProgress: Int, CaseIterable {
        case email
        case newPassword
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.textColor = .almostBlack
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 20)
        
        return titleLabel
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 1.6)
        progressView.trackTintColor = .gray3
        progressView.progressTintColor = .almostBlack
        
        return progressView
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 36).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        
        addSubview(progressView)
        progressView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 28).isActive = true
        progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40).isActive = true
        progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40).isActive = true
        progressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -28).isActive = true
    }
    
    private func value(stepCount: Int, currentStep: Int) -> Float {
        let percent: Float = Float(100 / stepCount) + 1
        let realValue: Float = Float(currentStep + 1) * percent
        
        return realValue / 100
    }
    
    func setup(with model: Model) {
        titleLabel.text = model.text
        progressView.progress = value(stepCount: model.stepCount, currentStep: model.currentStep)
    }
}
