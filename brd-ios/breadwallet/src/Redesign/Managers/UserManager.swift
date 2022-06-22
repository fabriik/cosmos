// 
//  UserManager.swift
//  breadwallet
//
//  Created by Rok on 22/06/2022.
//  Copyright © 2022 Fabriik Exchange, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

class UserManager: NSObject {
    
    static var shared: UserManager = UserManager()
    var dataChanged = [((Profile?, Error?) -> Void)]()
    var profile: Profile?
    var error: Error?
    
    override init() {
        super.init()
        refresh()
    }
    
    func refresh(completion: ((Profile?) -> Void)? = nil) {
        ProfileWorker().execute { [weak self] profile, error in
            print("Error: \(error?.firstOccurringError() ?? "<No error>")")
            self?.profile = profile
            self?.error = error
            self?.dataChanged.forEach({ $0(profile, error) })
            
            completion?(profile)
            
            guard UserDefaults.email == nil else { return }
            UserDefaults.email = profile?.email
        }
    }
}
