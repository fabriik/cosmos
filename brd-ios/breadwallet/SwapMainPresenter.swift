//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapMainPresentationLogic {
    // MARK: Presentation logic functions
    
    func presentFillData(response: SwapMain.FillData.Response)
}

class SwapMainPresenter: SwapMainPresentationLogic {
    weak var viewController: SwapMainDisplayLogic?
    
    // MARK: Presenter functions
    
    func presentFillData(response: SwapMain.FillData.Response) {
        viewController?.displayFillData(viewModel: .init(sendAmount: response.sendAmount))
    }
}
