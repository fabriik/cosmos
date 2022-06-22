//
//  EQNetworking
//  Copyright © 2022 Equaleyes Ltd. All rights reserved.
//

import Foundation

class BaseResponseWorker<T: ModelResponse, U: Model, V: ModelMapper<T, U>>: APICallWorker {
    typealias Completion = (Result<U, Error>) -> Void
    
    var requestData: RequestModelData?
    
    var completion: Completion?
    var result: U?
    
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
        if let data = result {
            completion?(.success(data))
        } else if let error = response.error {
            completion?(.failure(error))
        }
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
}
