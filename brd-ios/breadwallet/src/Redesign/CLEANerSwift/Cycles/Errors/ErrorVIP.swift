//
//  File.swift
//  
//
//  Created by Rok Cresnik on 01/12/2021.
//

import Foundation

protocol ErrorViewActions {}

protocol ErrorActionResponses {
    func presentError(actionResponse: ErrorModels.Errors.ActionResponse)
}

protocol ErrorResponseDisplays {
    func displayError(responseDisplay: ErrorModels.Errors.ResponseDisplay)
}
