//
//  Alertable.swift
//  
//
//  Created by Rok Cresnik on 08/12/2021.
//

import UIKit

protocol Alertable {
    var title: String? { get }
    var description: String? { get }
    var image: UIImage? { get }
    var tintColor: UIColor? { get }
//    var primaryConfiguration: ButtonConfiguration? { get }
//    var secondaryConfiguration: ButtonConfiguration? { get }
//    var tertiaryConfigraution: ButtonConfiguration? { get }
}
