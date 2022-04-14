// 
// Created by Equaleyes Solutions Ltd
//

import Foundation

struct Validator {
    static func validatePassword(value: String, completion: ((Bool) -> Void)? = nil) -> Bool {
        let format = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", format)
        
        let isViable = predicate.evaluate(with: value)
        
        completion?(isViable)
        
        return isViable
    }
    
    static func validateEmail(value: String, completion: ((Bool) -> Void)? = nil) -> Bool {
        let format = "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", format)
        
        let isViable = predicate.evaluate(with: value)
        
        completion?(isViable)
        
        return isViable
    }
    
    static func validatePhoneNumber(value: String, completion: ((Bool) -> Void)? = nil) -> Bool {
        let format = "^\\+[1-9][0-9]{5,20}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", format)
        
        let isViable = predicate.evaluate(with: value)
        
        completion?(isViable)
        
        return isViable
    }
    
    static func validateConfirmationCode(value: String, completion: ((Bool) -> Void)? = nil) -> Bool {
        let format = "^.{6,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", format)
        
        let isViable = predicate.evaluate(with: value)
        
        completion?(isViable)
        
        return isViable
    }
}
