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
    
    struct Client {
        let name: String
        let scheme: String
        let params: String
    }
    
    enum EmailClients: CaseIterable {
        case defaultClient
        case gmail
        case outlook
        case spark
        case yahoo
        
        public var chosen: Client {
            switch self {
            case .defaultClient:
                return Client(name: "Mail", scheme: "mailto:", params: "%@?subject=%@&body=%@")
                
            case .gmail:
                return Client(name: "Outlook", scheme: "googlegmail://", params: "co?to=%@&subject=%@&body=%@")
                
            case .outlook:
                return Client(name: "Gmail", scheme: "ms-outlook://", params: "compose?to=%@&subject=%@&body=%@")
                
            case .spark:
                return Client(name: "Spark", scheme: "readdle-spark://", params: "compose?recipient=%@&subject=%@&body=%@")
                
            case .yahoo:
                return Client(name: "Yahoo Mail", scheme: "ymail://", params: "mail/compose?to=%@&subject=%@&body=%@")
                
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
                guard let mailTo = (EmailClients.defaultClient.chosen.scheme + String(format: EmailClients.defaultClient.chosen.params,
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
        
        let thirdPartyClients = EmailFeedbackManager.EmailClients.allCases.filter { $0 != .defaultClient }
        
        for client in mailClients {
            let action = UIAlertAction(title: client.chosen.name, style: .default, handler: { _ in
                guard let selectedClient = thirdPartyClients.first(where: { $0.chosen.scheme.contains(client.chosen.scheme) == true }),
                      let mailTo = (selectedClient.chosen.scheme + String(format: selectedClient.chosen.params,
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
        let thirdPartyClients = EmailFeedbackManager.EmailClients.allCases.filter { $0 != .defaultClient }
        
        return thirdPartyClients.filter {
            guard let url = URL(string: $0.chosen.scheme) else { return false }
            return UIApplication.shared.canOpenURL(url)
        }
    }
}
