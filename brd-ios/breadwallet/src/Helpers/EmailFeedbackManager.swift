// 
// Created by Equaleyes Solutions Ltd
//

import Foundation
import MessageUI

class EmailFeedbackManager: NSObject, MFMailComposeViewControllerDelegate {
    struct Feedback {
        let recipients: String
        let subject: String
        let body: String
    }
    
    enum EmailClients: CaseIterable {
        case defaultClient
        case gmail
        case outlook
        case spark
        case yahoo
        
        var name: String {
            switch self {
            case .defaultClient:
                return "Mail"
                
            case .gmail:
                return "Gmail"
                
            case .outlook:
                return "Outlook"
                
            case .spark:
                return "Spark"
                
            case .yahoo:
                return "Yahoo Mail"
                
            }
        }
        
        var scheme: String {
            switch self {
            case .defaultClient:
                return "mailto:"
                
            case .gmail:
                return "googlegmail://"
                
            case .outlook:
                return "ms-outlook://"
                
            case .spark:
                return "readdle-spark://"
                
            case .yahoo:
                return "ymail://"
                
            }
        }
        
        var params: String {
            switch self {
            case .defaultClient:
                return "%@?subject=%@&body=%@"
                
            case .gmail:
                return "co?to=%@&subject=%@&body=%@"
                
            case .outlook:
                return "compose?to=%@&subject=%@&body=%@"
                
            case .spark:
                return "compose?recipient=%@&subject=%@&body=%@"
                
            case .yahoo:
                return "mail/compose?to=%@&subject=%@&body=%@"
                
            }
        }
    }
    
    private var superVC = UIViewController()
    private let mailVC = MFMailComposeViewController()
    private var feedback: Feedback
    private var completion: ((Result<MFMailComposeResult, Error>) -> Void)?
    
    override init() {
        fatalError("Use FeedbackManager(feedback:)")
    }
    
    init?(feedback: Feedback, on viewController: UIViewController) {
        guard MFMailComposeViewController.canSendMail() else {
            if #available(iOS 14.0, *) {
                guard let mailTo = (EmailClients.defaultClient.scheme + String(format: EmailClients.defaultClient.params,
                                                                               feedback.recipients,
                                                                               feedback.subject,
                                                                               feedback.body))
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let url = URL(string: mailTo) else { return nil }
                
                UIApplication.shared.open(url)
            } else {
                EmailFeedbackManager.showAvailableMailClientsAlert(on: viewController, with: feedback)
            }
            
            return nil
        }
        
        self.feedback = feedback
        self.superVC = viewController
    }
    
    func send(completion:(@escaping(Result<MFMailComposeResult, Error>) -> Void)) {
        self.completion = completion
        
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients([feedback.recipients])
        mailVC.setSubject(feedback.subject)
        mailVC.setMessageBody(feedback.body, isHTML: false)
        
        superVC.present(mailVC, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        mailVC.dismiss(animated: true)
        
        if let error = error {
            completion?(.failure(error))
        } else {
            completion?(.success(result))
        }
    }
}

extension EmailFeedbackManager {
    static func showAvailableMailClientsAlert(on viewController: UIViewController, with feedback: EmailFeedbackManager.Feedback) {
        let mailClients = getAllAvailableMailClients()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for client in mailClients {
            let action = UIAlertAction(title: client.name, style: .default, handler: { _ in
                guard let selectedClient = mailClients.first(where: { $0.scheme.contains(client.scheme) == true }),
                      let mailTo = (selectedClient.scheme + String(format: selectedClient.params,
                                                                   feedback.recipients,
                                                                   feedback.subject,
                                                                   feedback.body))
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let url = URL(string: mailTo) else { return }
                
                UIApplication.shared.open(url)
            })
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        viewController.present(alert, animated: true)
    }
    
    private static func getAllAvailableMailClients() -> [EmailFeedbackManager.EmailClients] {
        let allClients = EmailFeedbackManager.EmailClients.allCases
        
        return allClients.filter {
            guard let url = URL(string: $0.scheme) else { return false }
            return UIApplication.shared.canOpenURL(url)
        }
    }
}
