//
//  StateDisplayable.swift
//  
//
//  Created by Rok Cresnik on 07/09/2021.
//

import UIKit

enum DisplayState {
    case normal
    case selected
    case highlighted
    case disabled
}

protocol StateDisplayable {
    func animateTo(state: DisplayState, withAnimation: Bool)
}
