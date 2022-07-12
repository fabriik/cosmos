//
// Created by Equaleyes Solutions Ltd
//

import UIKit

final class VerifyAccountPresenter: NSObject, Presenter, VerifyAccountActionResponses {
    
    typealias Models = VerifyAccountModels

    weak var viewController: VerifyAccountViewController?
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        
        let sections: [Models.Section] = [
            .image,
            .title,
            .description
        ]
        
        let sectionRows: [Models.Section: [Any]] =
        [
            .image: [ ImageViewModel.imageName("VerifyAccount") ],
            .title: [LabelViewModel.text("Verify your account to get full access to your Fabriik wallet!")],
            .description: [ LabelViewModel.text("We need to verify your identity in order to buy/sell and swap crypto.") ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    // MARK: - VerifyAccountActionResponses

    // MARK: - Additional Helpers

}
