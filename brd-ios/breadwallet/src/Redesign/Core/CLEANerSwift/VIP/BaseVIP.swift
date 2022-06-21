//
//  BaseVIP.swift
//  MagicFactory
//
//  Created by Rok Cresnik on 20/08/2021.
//

import UIKit

protocol BaseViewActions {}

protocol BaseActionResponses: MessageActionResponses {}

protocol BaseResponseDisplays: MessageResponseDisplays {}

protocol BaseDataStore {}

protocol BaseDataPassing {
    associatedtype Store: BaseDataStore
    var dataStore: Store? { get }
}

protocol CoordinatableRoutes: NSObject,
                              MessageDisplayable {
    func goBack()
}

protocol MessageDisplayable {
    func showMessage(with error: Error?, model: InfoViewModel?, configuration: InfoViewConfiguration?)
    func hideMessage(_ view: UIView)
}
