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
        ProfileWorker().execute { [weak self] result in
            switch result {
            case .success(let profile):
                self?.profile = profile
                
                if let email = profile.email {
                    UserDefaults.email = email
                }
                
            case .failure(let error):
                self?.error = error
            }
            
            self?.dataChanged.forEach({ $0(self?.profile, self?.error) })
            completion?(self?.profile)
        }
    }
}
