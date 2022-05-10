//
//  Interactor.swift
//  MagicFactory
//
//  Created by Rok Cresnik on 20/08/2021.
//

import Foundation

protocol Interactor: NSObject, BaseViewActions {
    associatedtype ActionResponses: BaseActionResponses
    associatedtype Store: BaseDataStore
    
    var presenter: ActionResponses? { get set }
    var dataStore: Store? { get set }
}
