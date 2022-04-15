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
        
        static let defaultClient = Client(name: "Mail", scheme: "mailto:", params: "%@?subject=%@&body=%@")
        static let gmail = Client(name: "Outlook", scheme: "googlegmail://", params: "co?to=%@&subject=%@&body=%@")
        static let outlook = Client(name: "Gmail", scheme: "ms-outlook://", params: "compose?to=%@&subject=%@&body=%@")
        static let spark = Client(name: "Spark", scheme: "readdle-spark://", params: "compose?recipient=%@&subject=%@&body=%@")
        static let yahoo = Client(name: "Yahoo Mail", scheme: "ymail://", params: "mail/compose?to=%@&subject=%@&body=%@")
        static let thirdPartyClients = [gmail, outlook, spark, yahoo]
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
                guard let mailTo = (Client.defaultClient.scheme + String(format: Client.defaultClient.params,
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
        
        let thirdPartyClients = EmailFeedbackManager.Client.thirdPartyClients
        
        for client in mailClients {
            let action = UIAlertAction(title: client.name, style: .default, handler: { _ in
                guard let selectedClient = thirdPartyClients.first(where: { $0.scheme.contains(client.scheme) == true }),
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
    
    private static func getAllAvailableMailClients() -> [EmailFeedbackManager.Client] {
        return EmailFeedbackManager.Client.thirdPartyClients.filter {
            guard let url = URL(string: $0.scheme) else { return false }
            return UIApplication.shared.canOpenURL(url)
        }
    }
}
