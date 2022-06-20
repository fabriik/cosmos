// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

class AboutViewController: UIViewController {
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(font: .customBold(size: 26.0), color: .almostBlack)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = L10n.About.title
        
        return titleLabel
    }()
    
    private lazy var aboutHeaderView: AboutHeaderView = {
        let aboutHeaderView = AboutHeaderView()
        aboutHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        return aboutHeaderView
    }()
    
    private lazy var aboutFooterView: UILabel = {
        let aboutFooterView = UILabel.wrapping(font: .customBody(size: 13.0), color: Theme.primaryText)
        aboutFooterView.translatesAutoresizingMaskIntoConstraints = false
        aboutFooterView.textAlignment = .center
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            aboutFooterView.text = L10n.About.footer(version, build)
        }
        
        return aboutFooterView
    }()
    
    private lazy var privacy: UIButton = {
        let privacy = UIButton(type: .system)
        privacy.translatesAutoresizingMaskIntoConstraints = false
        privacy.setTitle(L10n.About.privacy, for: .normal)
        privacy.titleLabel?.font = UIFont.customBody(size: 13.0)
        privacy.tintColor = .primaryButton
        
        return privacy
    }()
    
    private lazy var terms: UIButton = {
        let terms = UIButton(type: .system)
        terms.translatesAutoresizingMaskIntoConstraints = false
        terms.setTitle(L10n.About.terms, for: .normal)
        terms.titleLabel?.font = UIFont.customBody(size: 13.0)
        terms.tintColor = .primaryButton
        
        return terms
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.About.title
        
        addSubviews()
        addConstraints()
        setActions()
        
        view.backgroundColor = .darkBackground
    }

    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(aboutHeaderView)
        view.addSubview(privacy)
        view.addSubview(terms)
        view.addSubview(aboutFooterView)
    }

    private func addConstraints() {
        titleLabel.constrain([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: C.padding[2]) ])
        
        let verticalMargin = (E.isIPhone6OrSmaller) ? C.padding[1] : C.padding[2]
        
        aboutHeaderView.constrain([
            aboutHeaderView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: verticalMargin),
            aboutHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            aboutHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor) ])
        terms.constrain([
            terms.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            terms.topAnchor.constraint(equalTo: aboutHeaderView.bottomAnchor, constant: verticalMargin)])
        privacy.constrain([
            privacy.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            privacy.topAnchor.constraint(equalTo: terms.bottomAnchor)])
        aboutFooterView.constrain([
            aboutFooterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[3]),
            aboutFooterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[3]),
            aboutFooterView.topAnchor.constraint(equalTo: privacy.bottomAnchor, constant: verticalMargin)])
    }
    
    private func setActions() {
        privacy.tap = { [weak self] in
            self?.presentURL(string: C.privacyPolicy, title: self?.privacy.titleLabel?.text ?? "")
        }
        
        terms.tap = { [weak self] in
            self?.presentURL(string: C.termsAndConditions, title: self?.terms.titleLabel?.text ?? "")
        }
    }

    private func presentURL(string: String, title: String) {
        guard let url = URL(string: string) else { return }
        let webViewController = SimpleWebViewController(url: url)
        webViewController.setup(with: .init(title: title))
        
        navigationController?.pushViewController(webViewController, animated: true)
    }
}
