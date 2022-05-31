//
//  PersonalInfoPresenter.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

final class PersonalInfoPresenter: NSObject, Presenter, PersonalInfoActionResponses {
    typealias Models = PersonalInfoModels

    weak var viewController: PersonalInfoViewController?

    // MARK: - PersonalInfoActionResponses

    // MARK: - Additional Helpers
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        let sections: [Models.Section] = [
            .name,
            .country,
            .birthdate,
            .confirm
        ]
        
        let sectionRows: [Models.Section: [Any]] = [
            .name: [
                NameViewModel(title: .text("Write your name as it appears on your ID"),
                              firstName: .init(title: "First Name", value: item.firstName, validator: { $0?.isEmpty == false }),
                              lastName: .init(title: "Last Name", value: item.lastName, validator: { $0?.isEmpty == false }))
            ],
            .country: [ TextFieldModel(title: "Country", value: item.country, error: "to short", validator: { $0?.isEmpty == false }) ],
            .birthdate: [ TextFieldModel(title: "Date of birth", value: "\(item.birthdate ?? Date())", error: "to short", validator: { $0?.isEmpty == false }) ],
            .confirm: [
                "Confirm"
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
}
