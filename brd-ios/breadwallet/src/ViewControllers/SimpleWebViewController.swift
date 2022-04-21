// 
// Created by Equaleyes Solutions Ltd
//

import UIKit
import SafariServices

class SimpleWebViewController: SFSafariViewController, SFSafariViewControllerDelegate {
    struct Model {
        var title: String
    }
    
    func setup(with model: Model) {
        title = model.title
        delegate = self
    }
    
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        guard URL.lastPathComponent == "success" else { return }
        navigationController?.dismiss(animated: true)
    }
}
