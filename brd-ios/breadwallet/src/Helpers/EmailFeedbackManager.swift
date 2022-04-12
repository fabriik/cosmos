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
    
    private var feedback: Feedback
    private var completion: ((Result<MFMailComposeResult, Error>) -> Void)?
    
    override init() {
        fatalError("Use FeedbackManager(feedback:)")
    }
    
    init?(feedback: Feedback) {
        guard MFMailComposeViewController.canSendMail() else {
            return nil
        }
        
        self.feedback = feedback
    }
    let mailVC = MFMailComposeViewController()

    func send(on viewController: UIViewController, completion:(@escaping(Result<MFMailComposeResult, Error>) -> Void)) {
        self.completion = completion
        
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients([feedback.recipients])
        mailVC.setSubject(feedback.subject)
        mailVC.setMessageBody(feedback.body, isHTML: false)
        
        viewController.present(mailVC, animated: true)
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
