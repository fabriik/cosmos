// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

class KYCTextAndImageView: BaseViewDeprecated, GenericSettable {
    typealias Model = ViewModel
    
    struct ViewModel: Hashable {
        let text: String
        let image: UIImage?
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .almostBlack
        label.font = UIFont(name: "AvenirNext-Regular", size: 20)
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var bigImageView: UIImageView = {
        let bigImageView = UIImageView()
        bigImageView.translatesAutoresizingMaskIntoConstraints = false
        bigImageView.contentMode = .scaleAspectFit
        
        return bigImageView
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(label)
        label.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        addSubview(bigImageView)
        bigImageView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 38).isActive = true
        bigImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        bigImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        bigImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bigImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    func setup(with model: ViewModel) {
        label.text = model.text
        bigImageView.image = model.image
    }
}
