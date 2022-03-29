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
        // TODO: I don't know how any of these will work yet. Literally 0 clue. Will have a meeting with Ziga and Victor to figure out.
        // Don't want to randomly mock everything and lose time as I am already mocking quite some stuff.
        
        sendAmount = request.sendAmount?.isEmpty == true ? "0" : request.sendAmount ?? ""
        
        presenter?.presentFillData(response: .init(sendAmount: sendAmount))
    }
}
