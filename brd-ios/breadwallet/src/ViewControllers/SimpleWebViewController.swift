// 
// Created by Equaleyes Solutions Ltd
//

import UIKit
import WebKit

class SimpleWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .clear
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        return webView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        activityIndicator.style = .gray
        activityIndicator.hidesWhenStopped = true
        
        return activityIndicator
    }()
    
    var showDismissButton = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Support"
        
        view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        webView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor).isActive = true
        
        view.backgroundColor = .white
        
        guard showDismissButton else { return }
        
        let dismissButton = UIBarButtonItem(title: "Dismiss", style: .done, target: self, action: #selector(dismissSupport))
        navigationItem.leftBarButtonItem = dismissButton
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
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
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
}
