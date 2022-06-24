//
//  KYCBasicPresenter.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

final class KYCBasicPresenter: NSObject, Presenter, KYCBasicActionResponses {
    typealias Models = KYCBasicModels

    weak var viewController: KYCBasicViewController?

    // MARK: - KYCBasicActionResponses

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
            .country: [
                TextFieldModel(title: "Country",
                               value: item.countryFullName,
                               error: "too short",
                               trailing: .imageName("chevrondown"),
                               validator: { $0?.isEmpty == false })
            ],
            .birthdate: [
                DateViewModel(date: item.birthdate)
            ],
            .confirm: [
                ButtonViewModel(title: "Confirm")
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentValidate(actionResponse: KYCBasicModels.Validate.ActionResponse) {
        var fieldValidationIsAllowed = [String?: Bool]()
        
        fieldValidationIsAllowed[actionResponse.item?.firstName] = (actionResponse.item?.firstName?.count ?? 0) >= 1
        fieldValidationIsAllowed[actionResponse.item?.lastName] = (actionResponse.item?.lastName?.count ?? 0) >= 1
        fieldValidationIsAllowed[actionResponse.item?.country] = (actionResponse.item?.country?.count ?? 0) >= 1
        fieldValidationIsAllowed[actionResponse.item?.birthDateString] = actionResponse.item?.birthDateString != nil
        
        let isValid = fieldValidationIsAllowed.values.contains(where: { $0 == false }) == false
        
        viewController?.displayValidate(responseDisplay: .init(isValid: isValid))
    }
    
    func presentSubmit(actionResponse: KYCBasicModels.Submit.ActionResponse) {
        viewController?.displaySubmit(responseDisplay: .init())
    }
}
