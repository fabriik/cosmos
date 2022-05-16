// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

class ManageAssetsButton: RoundedView {
    var didTap: (() -> Void)?
    
    private lazy var manageAssetsButton: UIButton = {
        let manageAssetsButton = UIButton()
        manageAssetsButton.translatesAutoresizingMaskIntoConstraints = false
        manageAssetsButton.titleLabel?.font = Theme.body1
        manageAssetsButton.tintColor = Theme.tertiaryBackground
        manageAssetsButton.setTitleColor(Theme.blueBackground, for: .normal)
        manageAssetsButton.setTitleColor(Theme.transparentBlue, for: .highlighted)
        
        manageAssetsButton.layer.borderColor = UIColor.gray2.cgColor
        manageAssetsButton.layer.borderWidth = 0.5
        manageAssetsButton.layer.cornerRadius = C.Sizes.homeCellCornerRadius
        
        manageAssetsButton.contentHorizontalAlignment = .center
        manageAssetsButton.contentVerticalAlignment = .center
        
        manageAssetsButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        return manageAssetsButton
    }()
    
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func set(title: String) {
        manageAssetsButton.setTitle(title, for: .normal)
    }
    
    private func setup() {
        backgroundColor = .clear
        
        addSubview(manageAssetsButton)
        manageAssetsButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        manageAssetsButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        manageAssetsButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        manageAssetsButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    @objc private func buttonTapped() {
        didTap?()
    }
}
