// 
// Created by Equaleyes Solutions Ltd
// 

import UIKit

enum KYCTutorial {
    // MARK: Model name declarations
    
    enum FetchTutorialPages {
        struct Request {}
        struct Response {}
        struct ViewModel {}
    }
    
    enum HandleTutorialPaging {
        struct Request {
            let row: Int
            let pageCount: Int
        }
        struct Response {
            let nextPage: Int
        }
        struct ViewModel {
            let nextPage: Int
        }
    }
}
