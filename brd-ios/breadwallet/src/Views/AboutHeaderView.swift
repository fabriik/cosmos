// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

class AboutHeaderView: UIView {
    private lazy var mainLogoView: UIImageView = {
        let mainLogoView = UIImageView(image: UIImage(named: "LogoBlue"))
        mainLogoView.translatesAutoresizingMaskIntoConstraints = false
        mainLogoView.contentMode = .scaleAspectFit
        
        return mainLogoView
    }()
    
    private lazy var mainLogoTextView: UIImageView = {
        let mainLogoTextView = UIImageView(image: UIImage(named: "LogoBlueOnlyText"))
        mainLogoTextView.translatesAutoresizingMaskIntoConstraints = false
        mainLogoTextView.contentMode = .scaleAspectFit
        
        return mainLogoTextView
    }()
    
    private lazy var separator: UIView = {
        let separator = UIView(color: .secondaryShadow)
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        return separator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupSubviews()
    }
    
    func setupSubviews() {
        addSubview(mainLogoView)
        addSubview(mainLogoTextView)
        addSubview(separator)
        
        mainLogoView.constrain([
            mainLogoView.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainLogoView.topAnchor.constraint(equalTo: topAnchor, constant: C.padding[2]),
            mainLogoView.widthAnchor.constraint(equalToConstant: 50),
            mainLogoView.heightAnchor.constraint(equalToConstant: 50) ])
        mainLogoTextView.constrain([
            mainLogoTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: C.padding[2]),
            mainLogoTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[2]),
            mainLogoTextView.topAnchor.constraint(equalTo: mainLogoView.bottomAnchor, constant: C.padding[2]),
            mainLogoTextView.heightAnchor.constraint(equalTo: mainLogoView.heightAnchor) ])
        separator.constrain([
            separator.topAnchor.constraint(equalTo: mainLogoTextView.bottomAnchor, constant: C.padding[3]),
            separator.leadingAnchor.constraint(equalTo: mainLogoTextView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: mainLogoTextView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0) ])
    }
}
