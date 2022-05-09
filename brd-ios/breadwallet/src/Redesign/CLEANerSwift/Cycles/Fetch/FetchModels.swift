//
//  FetchModels.swift
//  
//
//  Created by Rok Cresnik on 02/12/2021.
//

import Foundation

enum AccessoryType: Hashable {
    case plain(String)
    case attributed(NSAttributedString)
    case action(String)

    func hash(into hasher: inout Hasher) {
        hasher.combine(title.hashValue)
    }

    var title: String {
        switch self {
        case .plain(let text):
            return text

        case .attributed(let text):
            return text.string

        case .action(let title):
            return title
        }
    }
}

protocol Sectionable {
    var header: AccessoryType? { get }
    var footer: AccessoryType? { get }
}

enum FetchModels {
    typealias Item = Any

    struct Get {
        struct ViewAction {
            init() {}
        }

        struct ActionResponse {
            let item: Item?

            init(item: Item?) {
                self.item = item
            }
        }

        struct ResponseDisplay {
            var sections: [AnyHashable]
            var sectionRows: [AnyHashable: [Any]]

            init(sections: [AnyHashable],
                        sectionRows: [AnyHashable: [Any]]) {
                self.sections = sections
                self.sectionRows = sectionRows
            }
        }
    }
}
