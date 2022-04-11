// 
// Created by Equaleyes Solutions Ltd
//

import Foundation

struct Validator {
    static func validatePassword(value: String, completion: (_ isViable: Bool) -> Void) -> Bool {
        let format = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let numberPredicate = NSPredicate(format: "SELF MATCHES %@", format)
        
        let isViable = numberPredicate.evaluate(with: value)
        
        completion(isViable)
        
        return isViable
    }
    
    static func validateEmail(value: String, completion: (_ isViable: Bool) -> Void) -> Bool {
        let format = "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+"
        let numberPredicate = NSPredicate(format: "SELF MATCHES %@", format)
        
        let isViable = numberPredicate.evaluate(with: value)
        
        completion(isViable)
        
        return isViable
    }
    
    static func validatePhoneNumber(value: String, completion: (_ isViable: Bool) -> Void) -> Bool {
        let format = "^\\+[1-9][0-9]{5,20}$"
        let numberPredicate = NSPredicate(format: "SELF MATCHES %@", format)
        
        let isViable = numberPredicate.evaluate(with: value)
        
        return isViable
    }
}
