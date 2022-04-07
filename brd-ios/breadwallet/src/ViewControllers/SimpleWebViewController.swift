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
    
    private lazy var backwardButton: UIBarButtonItem = {
        let backwardButton = UIBarButtonItem()
        
        return backwardButton
    }()
    
    private lazy var forwardButton: UIBarButtonItem = {
        let forwardButton = UIBarButtonItem()
        
        return forwardButton
    }()
    
    var showDismissButton = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Support"
        
        view.addSubview(toolbar)
        toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        var items = [UIBarButtonItem]()
        
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        
        backwardButton = UIBarButtonItem(barButtonSystemItem: .rewind, target: nil, action: #selector(backAction))
        backwardButton.isEnabled = false
        items.append(backwardButton)
        
        forwardButton = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(forwardAction))
        forwardButton.isEnabled = false
        items.append(forwardButton)
        
        toolbar.setItems(items, animated: false)
        
        view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor).isActive = true
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
        backwardButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
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
