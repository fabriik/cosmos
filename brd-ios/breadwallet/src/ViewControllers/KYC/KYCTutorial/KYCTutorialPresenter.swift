// 
// Created by Equaleyes Solutions Ltd
// 

import UIKit

protocol KYCTutorialPresentationLogic {
    // MARK: Presentation logic functions
    
    func presentTutorialPages(response: KYCTutorial.FetchTutorialPages.Response)
    func presentNextTutorial(response: KYCTutorial.HandleTutorialPaging.Response)
}

class KYCTutorialPresenter: KYCTutorialPresentationLogic {
    weak var viewController: KYCTutorialDisplayLogic?
    
    // MARK: Presenter functions
    
    func presentTutorialPages(response: KYCTutorial.FetchTutorialPages.Response) {
        viewController?.displayTutorialPages(viewModel: .init())
    }
    
    func presentNextTutorial(response: KYCTutorial.HandleTutorialPaging.Response) {
        viewController?.displayNextTutorial(viewModel: .init(nextPage: response.nextPage))
    }
}
