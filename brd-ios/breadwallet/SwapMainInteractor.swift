//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapMainBusinessLogic {
    // MARK: Business logic functions
    
    func executeFillData(request: SwapMain.FillData.Request)
}

protocol SwapMainDataStore {
    // MARK: Data store
    
    var sendAmount: String { get set }
}

class SwapMainInteractor: SwapMainBusinessLogic, SwapMainDataStore {
    var presenter: SwapMainPresentationLogic?
    
    // MARK: Interactor functions
    
    var sendAmount = ""
    
    func executeFillData(request: SwapMain.FillData.Request) {
        sendAmount = request.sendAmount?.isEmpty == true ? "0" : request.sendAmount ?? ""
        
        presenter?.presentFillData(response: .init(sendAmount: sendAmount))
    }
}
