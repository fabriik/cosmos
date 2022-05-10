// 
// Created by Equaleyes Solutions Ltd
// 

import UIKit

class KYCTutorial1CollectionView: UICollectionViewCell, Identifiable {
    // TODO: not needed anymore
    static var identifier: String { return classIdentifier }
    
    class var classIdentifier: String {
        return "WrappedCell\(String(describing: KYCTutorial1CollectionView.self))"
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
        titleLabel.text = "As a regulated financial services company, we are required to identify the users on our platform."
        
        return titleLabel
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.image = UIImage(named: "Tutorial1")
        
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
    
    private lazy var closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("CLOSE", for: .normal)
        closeButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 14)
        closeButton.setTitleColor(.gray2, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        return closeButton
    }()
    
    private lazy var nextButton: UIButton = {
        let nextButton = UIButton()
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("NEXT", for: .normal)
        nextButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 14)
        nextButton.setTitleColor(.vibrantYellow, for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        return nextButton
    }()
    
    var didTapCloseButton: (() -> Void)?
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
        buttonsStackView.addArrangedSubview(closeButton)
        buttonsStackView.addArrangedSubview(nextButton)
        buttonsStackView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        buttonsStackView.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor, constant: 40).isActive = true
        buttonsStackView.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor, constant: -40).isActive = true
    }
    
    @objc func closeButtonTapped() {
        didTapCloseButton?()
    }
    
    @objc func nextButtonTapped() {
        didTapNextButton?()
    }
}
