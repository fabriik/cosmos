// 
// Created by Equaleyes Solutions Ltd
//

import Foundation

/// For setting variables (non static content)
protocol GenericSettable {
    associatedtype Model
    func setup(with model: Model)
}

/// For configuring the views UI
protocol ViewConfigurable {
    associatedtype ViewConfig
    func configure(with viewConfig: ViewConfig)
}
