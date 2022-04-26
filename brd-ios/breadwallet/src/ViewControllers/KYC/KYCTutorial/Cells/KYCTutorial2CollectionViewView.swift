// 
// Created by Equaleyes Solutions Ltd
// 

import UIKit

class KYCTutorial2CollectionView: UICollectionViewCell, Identifiable {
    static var identifier: String { return classIdentifier }
    
    class var classIdentifier: String {
        return "WrappedCell\(String(describing: KYCTutorial2CollectionView.self))"
    }
    
    private lazy var containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.spacing = 0
        stack.backgroundColor = .clear
        
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.textColor = Theme.primaryBackground
        titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 20)
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        // swiftlint:disable line_length
        titleLabel.text = "Please have a valid form of government issued ID such as a passport or drivers lisence ready.\nYou will also be asked to take a selfie, so before you start make sure that you are in a well-lit area."
        
        return titleLabel
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.image = UIImage(named: "Tutorial2")
        
        return imageView
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .fill
        stack.spacing = 0
        stack.backgroundColor = .clear
        
        return stack
    }()
    
    private lazy var nextButton: SimpleButton = {
        let nextButton = SimpleButton()
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setup(as: .kycEnabled, title: "BEGIN")
        
        nextButton.didTap = { [weak self] in
            self?.didTapNextButton?()
        }
        
        return nextButton
    }()
    
    var didTapNextButton: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
 
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    func setupSubviews() {        
        addSubview(containerStackView)
        containerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        containerStackView.addArrangedSubview(titleLabel)
        titleLabel.heightAnchor.constraint(equalTo: containerStackView.heightAnchor, multiplier: 0.26).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: containerStackView.widthAnchor, multiplier: 0.64).isActive = true
        
        containerStackView.addArrangedSubview(imageView)
        imageView.heightAnchor.constraint(equalTo: containerStackView.heightAnchor, multiplier: 0.54).isActive = true
        
        containerStackView.addArrangedSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(nextButton)
        buttonsStackView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        buttonsStackView.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor, constant: 40).isActive = true
        buttonsStackView.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor, constant: -40).isActive = true
    }
}
