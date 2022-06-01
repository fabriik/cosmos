//
//  EQNetworking
//  Copyright © 2022 Equaleyes Ltd. All rights reserved.
//

import Foundation

class BaseResponseWorker<T: ModelResponse, U: Model, V: ModelMapper<T, U>>: APICallWorker {
    typealias Completion = (U?, NetworkingError?) -> Void
    
    var requestData: RequestModelData?
    
    var completion: Completion?
    var result: U?
    
    override func getHeaders() -> [String: String] {
        var key = UserDefaults.kycSessionKeyValue
        
        if key.isEmpty,
           let tokenData: [AnyHashable: Any] = try? keychainItem(key: KeychainKey.apiUserAccount),
           let token = tokenData["token"] as? String {
            key = "Bread \(token)"
        }
        
        return ["Authorization": key]
    }
    
    func execute(requestData: RequestModelData? = nil, completion: Completion?) {
        self.requestData = requestData
        self.completion = completion
        execute()
    }
    
    func executeMultipartRequest(requestData: RequestModelData? = nil, completion: Completion?) {
        self.requestData = requestData
        self.completion = completion
        executeMultipartRequest()
    }
    
    override func processResponse(response: HTTPResponse) {
        guard let data = response.data, response.error == nil else { return }
        guard let payload = T.parse(from: data, type: T.self) else { return }
        let mapper = V()
        result = mapper.getModel(from: payload)
    }
    
    override func apiCallDidFinish(response: HTTPResponse) {
        completion?(result, response.error)
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
}
