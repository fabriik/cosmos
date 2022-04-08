// 
// Created by Equaleyes Solutions Ltd
//

import UIKit
import WebKit

class SimpleWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    struct Model {
        var title: String
        var showDismissButton: Bool = true
    }
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .clear
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        return webView
    }()
    
    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        return toolbar
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        activityIndicator.style = .gray
        activityIndicator.hidesWhenStopped = true
        
        return activityIndicator
    }()
    
    var showDismissButton = true {
        didSet {
            guard showDismissButton else {
                navigationItem.leftBarButtonItem = nil
                return
            }
            let dismissButton = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(dismissSupport))
            navigationItem.leftBarButtonItem = dismissButton
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backwardButton = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(backAction))
        backwardButton.isEnabled = false
        let forwardButton = UIBarButtonItem(title: ">", style: .plain, target: self, action: #selector(forwardAction))
        forwardButton.isEnabled = false
        navigationItem.rightBarButtonItems = [forwardButton, backwardButton]
        
        view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        webView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor).isActive = true
        
        view.backgroundColor = .white
    }
    
    @objc private func dismissSupport() {
        dismiss(animated: true)
    }
    
    func navigate(to: String) {
        guard let url = URL(string: to) else { return }
        let request = URLRequest(url: url)
        
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        
        handleNavigationBarButtonState()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        
        handleNavigationBarButtonState()
    }
    
    @objc private func backAction() {
        guard webView.canGoBack else { return }
        
        webView.goBack()
    }
    
    @objc private func forwardAction() {
        guard webView.canGoForward else { return }
        
        webView.goForward()
    }
    
    private func handleNavigationBarButtonState() {
        navigationItem.rightBarButtonItems?.first?.isEnabled = webView.canGoForward
        navigationItem.rightBarButtonItems?.last?.isEnabled = webView.canGoBack
    }
    
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let frame = navigationAction.targetFrame, frame.isMainFrame {
            return nil
        }
        
        webView.load(navigationAction.request)
        
        return nil
    }
    
    func setup(with model: Model) {
        title = model.title
        showDismissButton = model.showDismissButton
    }
}
