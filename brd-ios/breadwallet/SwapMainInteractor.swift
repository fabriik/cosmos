//
// Created by Equaleyes Solutions Ltd
//

import UIKit

protocol SwapMainBusinessLogic {
    // MARK: Business logic functions
}

protocol SwapMainDataStore {
    // MARK: Data store
}

class SwapMainInteractor: SwapMainBusinessLogic, SwapMainDataStore {
    var presenter: SwapMainPresentationLogic?
    
    // MARK: Interactor functions

}
