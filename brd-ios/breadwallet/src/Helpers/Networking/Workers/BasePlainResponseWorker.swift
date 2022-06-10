//
//  EQNetworking
//  Copyright © 2022 Equaleyes Ltd. All rights reserved.
//

import Foundation

class BasePlainResponseWorker: APICallWorker {
    // TODO: replace completion with the bellow
//    typealias Completion = (Result<Void, Error>) -> Void
    typealias Completion = (NetworkingError?) -> Void
    
    var requestData: RequestModelData?
    
    var completion: Completion?
    
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
    
    override func apiCallDidFinish(response: HTTPResponse) {
        completion?(response.error)
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
}
