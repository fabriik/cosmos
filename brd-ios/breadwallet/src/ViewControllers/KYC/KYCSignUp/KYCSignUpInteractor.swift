// 
// Created by Equaleyes Solutions Ltd
//

import UIKit
import CommonCrypto

protocol KYCSignUpBusinessLogic {
    // MARK: Business logic functions
    
    func executeGetDataForPickerView(request: KYCSignUp.GetDataForPickerView.Request)
    func executeCheckFieldPickerIndex(request: KYCSignUp.CheckFieldPickerIndex.Request)
    func executeCheckFieldType(request: KYCSignUp.CheckFieldText.Request)
    func executeCheckTickBox(request: KYCSignUp.CheckTickBox.Request)
    func executeSubmitData(request: KYCSignUp.SubmitData.Request)
}

protocol KYCSignUpDataStore {
    // MARK: Data store
    
    var firstName: String? { get set }
    var lastName: String? { get set }
    var email: String? { get set }
    var phonePrefix: String? { get set }
    var phoneNumber: String? { get set }
    var passwordOriginal: String? { get set }
    var password: String? { get set }
    var tickBox: Bool? { get set }
    
    var phonePrefixSelectedIndex: PickerViewViewController.Index? { get set }
    var phonePrefixName: String? { get set }
    
    var fieldValidationIsAllowed: [KYCSignUp.FieldType: Bool] { get set }
}

class KYCSignUpInteractor: KYCSignUpBusinessLogic, KYCSignUpDataStore {
    var presenter: KYCSignUpPresentationLogic?
    
    // MARK: Interactor functions
    
    var firstName: String?
    var lastName: String?
    var email: String?
    var phonePrefix: String?
    var phoneNumber: String?
    var passwordOriginal: String?
    var password: String?
    var tickBox: Bool?
    
    var phonePrefixSelectedIndex: PickerViewViewController.Index?
    var phonePrefixName: String?
    
    var fieldValidationIsAllowed = [KYCSignUp.FieldType: Bool]()
    
    func executeSubmitData(request: KYCSignUp.SubmitData.Request) {
        let worker = KYCSignUpWorker()
        let workerUrlModelData = KYCSignUpWorkerUrlModelData()
        let workerRequest = KYCSignUpWorkerRequest(firstName: firstName,
                                                   lastName: lastName,
                                                   email: email,
                                                   phone: (phonePrefix ?? "").replacingOccurrences(of: "+", with: "") + (phoneNumber ?? ""),
                                                   password: passwordOriginal)
        let workerData = KYCSignUpWorkerData(workerRequest: workerRequest,
                                             workerUrlModelData: workerUrlModelData)
        
        worker.execute(requestData: workerData) { [weak self] response, error in
            guard let sessionKey = response?.data["sessionKey"]?.value as? String, error == nil else {
                self?.presenter?.presentError(response: .init(error: error))
                return
            }
            
            UserDefaults.kycSessionKeyValue = sessionKey
            
            self?.presenter?.presentSubmitData(response: .init())
        }
    }
    
    func executeGetDataForPickerView(request: KYCSignUp.GetDataForPickerView.Request) {
        switch request.type {
        case .phonePrefix:
            presenter?.presentGetDataForPickerView(response: .init(index: phonePrefixSelectedIndex,
                                                                   type: request.type))
            
        default:
            break
            
        }
    }
    
    func executeCheckFieldPickerIndex(request: KYCSignUp.CheckFieldPickerIndex.Request) {
        let index = request.index
        let fieldValues = request.fieldValues
        
        switch request.type {
        case .phonePrefix:
            phonePrefix = index == nil ? nil : fieldValues[index?.row ?? 0]
            phonePrefixName = index == nil ? nil : fieldValues[index?.row ?? 0]
            phonePrefixSelectedIndex = index
            
        default:
            break
        }
        
        presenter?.presentSetPickerValue(response: .init(phonePrefix: phonePrefixName ?? ""))
        
        fieldValidationIsAllowed[request.type] = index != nil
        
        checkCredentials()
    }
    
    func executeCheckFieldType(request: KYCSignUp.CheckFieldText.Request) {
        switch request.type {
        case .firstName:
            firstName = request.text
            
        case .lastName:
            lastName = request.text
            
        case .email:
            email = request.text
            
        case .phoneNumber:
            phoneNumber = request.text
            
        case .password:
            passwordOriginal = request.text
            password = hashSHA512(data: Data((request.text ?? "").utf8))
            
        default:
            break
        }
        
        checkCredentials()
    }
    
    private func hashSHA512(data: Data) -> String? {
        var hashData = Data(count: Int(CC_SHA512_DIGEST_LENGTH))
                
        _ = hashData.withUnsafeMutableBytes { digestBytes in
            data.withUnsafeBytes { messageBytes in
                CC_MD5(messageBytes.baseAddress, CC_LONG(data.count), digestBytes.bindMemory(to: UInt8.self).baseAddress)
            }
        }
        
        // For hexadecimal output:
        return hashData.map { String(format: "%02hhx", $0) }.joined()
        // For Base64 output use this instead of the above:
        // return data.base64EncodedString()
    }
    
    func executeCheckTickBox(request: KYCSignUp.CheckTickBox.Request) {
        switch request.type {
        case .tickBox:
            tickBox = request.tickBox
            
        default:
            break
        }
        
        checkCredentials()
    }
    
    private func checkCredentials() {
        var validationValues = [Bool]()
        validationValues.append(!firstName.isNilOrEmpty)
        validationValues.append(!lastName.isNilOrEmpty)
        validationValues.append(!email.isNilOrEmpty)
        validationValues.append(!passwordOriginal.isNilOrEmpty)
        validationValues.append(!phonePrefix.isNilOrEmpty)
        validationValues.append(!phoneNumber.isNilOrEmpty)
        validationValues.append(tickBox == true)
        validationValues.append(Validator.validatePassword(value: passwordOriginal ?? "", completion: { [weak self] isViable in
            let isFieldEmpty = (self?.passwordOriginal ?? "").isEmpty
            
            self?.presenter?.presentValidateField(response: .init(isViable: isViable, isFieldEmpty: isFieldEmpty, type: .password))
        }))
        validationValues.append(Validator.validateEmail(value: email ?? "", completion: { [weak self] isViable in
            let isFieldEmpty = (self?.email ?? "").isEmpty
            
            self?.presenter?.presentValidateField(response: .init(isViable: isViable, isFieldEmpty: isFieldEmpty, type: .email))
        }))
        validationValues.append(Validator.validatePhoneNumber(value: (phonePrefix ?? "") + (phoneNumber ?? ""), completion: { [weak self] isViable in
            let isFieldEmpty = (self?.phonePrefix ?? "").isEmpty || (self?.phoneNumber ?? "").isEmpty
            
            self?.presenter?.presentValidateField(response: .init(isViable: isViable, isFieldEmpty: isFieldEmpty, type: .phoneNumber))
        }))
        validationValues.append(validateFirstName())
        validationValues.append(validateLastName())
        validationValues.append(contentsOf: fieldValidationIsAllowed.values)
        
        let shouldEnable = !validationValues.contains(false)
        
        presenter?.presentShouldEnableSubmit(response: .init(shouldEnable: shouldEnable))
    }
    
    private func validateFirstName() -> Bool {
        let isFieldEmpty = (firstName ?? "").isEmpty
        
        presenter?.presentValidateField(response: .init(isViable: !isFieldEmpty, isFieldEmpty: isFieldEmpty, type: .firstName))
        
        return !isFieldEmpty
    }
    
    private func validateLastName() -> Bool {
        let isFieldEmpty = (lastName ?? "").isEmpty
        
        presenter?.presentValidateField(response: .init(isViable: !isFieldEmpty, isFieldEmpty: isFieldEmpty, type: .lastName))
        
        return !isFieldEmpty
    }
}
