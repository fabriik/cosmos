//
//  EQNetworking
//  Copyright © 2022 Equaleyes Ltd. All rights reserved.
//

import Foundation

protocol APICallWorkerProperties {
    func execute()
    func executeMultipartRequest()
    func processResponse(response: HTTPResponse)
    func apiCallDidFinish(response: HTTPResponse)
    func getUrl() -> String
    func getMethod() -> HTTPMethod
    func getParameters() -> [String: Any]
    func getHeaders() -> [String: String]
    func getMultipartData() -> [MultipartMedia]
}
/**
 Super class for all workers that make api calls to API
 */
class APICallWorker: APICallWorkerProperties {
    var httpRequestManager = HTTPRequestManager()
    
    init() {}
    
    func execute() {
        let method = getMethod()
        let url = getUrl()
        let headers = getHeaders()
        let parameters = getParameters()
        
        let request = httpRequestManager.request(method, url: url, headers: headers, parameters: parameters)
        request.run { response in
            DispatchQueue.global(qos: .background).async {
                self.processResponse(response: response)
                DispatchQueue.main.async {
                    self.apiCallDidFinish(response: response)
                }
            }
        }
    }
    
    func executeMultipartRequest() {
        let method = getMethod()
        let url = getUrl()
        let headers = getHeaders()
        let parameters = getParameters()
        let myData = getMultipartData()
        
        let request = httpRequestManager.request(method, url: url, headers: headers, media: myData, parameters: parameters)
        request.runMultipartRequest { response in
            DispatchQueue.global(qos: .background).async {
                self.processResponse(response: response)
                DispatchQueue.main.async {
                    self.apiCallDidFinish(response: response)
                }
            }
        }
    }
    
    /**
     Function for any complex processing of http response. This function is called on a background thread.
     */
    func processResponse(response: HTTPResponse) { }
    
    /**
     Call completion from this function. This function is called on the main thread.
     */
    func apiCallDidFinish(response: HTTPResponse) { }
    func getUrl() -> String { return "" }
    func getMethod() -> HTTPMethod { return .get }
    func getParameters() -> [String: Any] { return [:] }
    
    func getHeaders() -> [String: String] {
        let key: String
        
        if let value = UserDefaults.kycSessionKeyValue {
            key = value
        } else if let value = UserDefaults.walletTokenValue {
            key = "Bread \(value)"
        } else {
            key = "no_token"
        }
        
        return ["Authorization": key]
    }
    
    func getMultipartData() -> [MultipartMedia] { return [] }
}
