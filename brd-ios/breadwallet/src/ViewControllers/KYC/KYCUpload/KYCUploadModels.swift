// 
// Created by Equaleyes Solutions Ltd
//

import UIKit

enum KYCUpload {
    // MARK: Model name declarations
    
    enum SaveImages {
        struct Request {
            let step: KYCUploadViewController.Step
        }
        struct Response {}
        struct ViewModel {}
    }
    
    enum SetImage {
        struct Request {
            let step: KYCUploadViewController.Step
            let image: UIImage
        }
    }
}
