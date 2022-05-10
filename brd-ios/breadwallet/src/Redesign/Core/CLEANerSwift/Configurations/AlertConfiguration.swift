//
//  AlertConfiguration.swift
//  
//
//  Created by Rok Cresnik on 08/12/2021.
//

import UIKit

protocol AlertConfigurable {
    associatedtype Config: ButtonConfigurable2

    var title: String? { get set }
    var description: String? { get set }
    var image: UIImage? { get set }
    var tintColor: UIColor? { get set }
    var mainButtonConfiguration: Config? { get set }
    var subButtonConfiguration: Config? { get set }
    var tertiaryConfiguration: Config? { get set }
}

protocol ButtonConfigurable2 {
    var title: String? { get set }
    // Also TextColor
    var tintColor: UIColor? { get set }
    var backgroundColor: UIColor? { get set }
    var callback: (() -> Void)? { get set }
}

// TODO: maybe part of the UI dependency and just leave protocol stubs here
struct AlertConfiguration: AlertConfigurable {
    public var title: String?
    public var description: String?
    public var image: UIImage?
    public var tintColor: UIColor?
    // TODO: make a callback array
    public var mainButtonConfiguration: ButtonConfiguration?
    public var subButtonConfiguration: ButtonConfiguration?
    public var tertiaryConfiguration: ButtonConfiguration?

    public var error: Error?

    public init(title: String? = nil,
                description: String? = nil,
                image: UIImage? = nil,
                tintColor: UIColor? = nil,
                mainButtonConfiguration: Config? = nil,
                subButtonConfiguration: Config? = nil,
                tertiaryConfiguration: Config? = nil,
                error: Error? = nil) {
        self.title = title
        self.description = description
        self.image = image
        self.tintColor = tintColor
        self.mainButtonConfiguration = mainButtonConfiguration
        self.subButtonConfiguration = subButtonConfiguration
        self.tertiaryConfiguration = tertiaryConfiguration
        self.error = error
    }
}

public struct ButtonConfiguration: ButtonConfigurable2 {
    public var title: String?
    public var tintColor: UIColor?
    public var backgroundColor: UIColor?
    public var callback: (() -> Void)?

    public init(title: String?,
                tintColor: UIColor? = nil,
                backgroundColor: UIColor? = nil,
                callback: (() -> Void)? = nil) {
        self.title = title
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.callback = callback
    }
}
