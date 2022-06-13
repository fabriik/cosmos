//
//  DocumentReviewStore.swift
//  breadwallet
//
//  Created by Rok on 13/06/2022.
//
//

import UIKit

class DocumentReviewStore: NSObject, BaseDataStore, DocumentReviewDataStore {
    // MARK: - DocumentReviewDataStore
    var itemId: String?
    var image: UIImage?
    var type: DocumentImageType = .front

    // MARK: - Aditional helpers
}
