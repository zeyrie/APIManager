// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public class APIManager {
    
    public static var requestTimeout: Double = 60
    private static let configuration = URLSessionConfiguration.default
    private static let session = URLSession(configuration: configuration)
    
    private var url: URL?
    private var requestMethod: APIRequestMethod = .UNDEFINED
    private var headers = [String: String]()
    private var jsonRootKey = String()
    private var requestBody: Any?
    private var urlRequest: URLRequest?
    
    
    public init(url: URL, requestMethod: APIRequestMethod, headers: [String : String] = [String: String](), jsonRootKey: String = String()) {
        self.url = url
        self.requestMethod = requestMethod
        self.headers = headers
        self.jsonRootKey = jsonRootKey
    }
    
    public func initializeRequest(with headers: [String: String]? = nil, and requestBody: [String: Any]?) async -> APIURLResponse<Data, HTTPURLResponse> {
        
        if let headers {
            headers.forEach( { key, value in
                self.headers[key] = value
            })
        }
        
        if let requestBody {
            self.requestBody = requestBody
        }
        
        // TODO: ZVZV Find a good reason to log here and the required details that has be logged.

        APILogger.shared.info("API Request is about to be hit")
        if let error = processRequest() {
            return .failure(error)
        }
        
        switch await makeRequest() {
        case .success(let data, let response):
            return .success(data, response)
        case .failure(let error):
            return .failure(error)
        }
        
    }
    
    public func initializeDownloadRequest(with headers: [String: String]? = nil, and requestBody: [String: Any]?) async -> APIURLResponse<URL, HTTPURLResponse> {
        
        if let headers {
            headers.forEach( { key, value in
                self.headers[key] = value
            })
        }
        
        if let requestBody {
            self.requestBody = requestBody
        }
        
        // TODO: ZVZV Find a good reason to log here and the required details that has be logged.
        
        APILogger.shared.info("API Request is about to be hit")
        if let error = processRequest() {
            return .failure(error)
        }
        
        switch await makeDownloadRequest() {
        case .success(let url, let response):
            return .success(url, response)
        case .failure(let error):
            return .failure(error)
        }
        
    }
    
    private func processRequest() -> APINetworkError? {
        guard let url else {
            APILogger.shared.error("\(APIErrorStatus.internalError) - Unable to construct URLRequest")
            return .apiManagerError(status: APIErrorStatus.internalError, message: "Unable to construct URLRequest", info: nil)
        }
        
        urlRequest = URLRequest(url: url)
        
        guard requestMethod != .UNDEFINED else {
            APILogger.shared.error("\(APIErrorStatus.invalidOperation) - Invalid Request Method")
            return .invalidError(status: APIErrorStatus.invalidOperation, message: "Invalid Request Method", info: nil)
        }
        
        urlRequest?.httpMethod = requestMethod.rawValue
        urlRequest?.cachePolicy = .reloadIgnoringLocalCacheData
        headers.forEach({ key, value in
            urlRequest?.setValue(value, forHTTPHeaderField: key)
        })
        
        if let requestBody = requestBody as? [String: Any], !requestBody.isEmpty {
            let body = try? JSONSerialization.data(withJSONObject: requestBody)
            urlRequest?.httpBody = body
        }
        
        return nil
    }
    
    private func makeRequest() async -> APIURLResponse<Data, HTTPURLResponse> {
        guard let urlRequest else {
            APILogger.shared.error("\(APIErrorStatus.internalError) - Request is nil")
            return .failure(.apiManagerError(status: APIErrorStatus.internalError, message: "Request is nil", info: nil))
        }
        
        APIManager.configuration.timeoutIntervalForRequest = APIManager.requestTimeout
        
        switch await APIManager.session.dataTask(with: urlRequest) {
        case .success(let data, let response):
            return .success(data, response)
        case .failure(let error):
            return .failure(error)
        }
        
    }
    
    private func makeDownloadRequest() async -> APIURLResponse<URL, HTTPURLResponse> {
        guard let urlRequest else {
            APILogger.shared.error("\(APIErrorStatus.internalError) - Request is nil")
            return .failure(.apiManagerError(status: APIErrorStatus.internalError, message: "Request is nil", info: nil))
        }
        
        APIManager.configuration.timeoutIntervalForRequest = APIManager.requestTimeout
        
        return await withCheckedContinuation { continuation in
            let task = APIManager.session.downloadTask(with: urlRequest) { response in
                continuation.resume(returning: response)
            }
            task.resume()
        }
    }
    
    public static func makeRequest(_ requestMethod: APIRequestMethod, withURL url: URL, headers: [String: String]?, requestBody: [String: Any]?) async -> APIURLResponse<Data, HTTPURLResponse> {
        let request = APIManager(url: url, requestMethod: requestMethod)
        return await request.initializeRequest(with: headers, and: requestBody)
    }
    
    public static func makeDownloadRequest(_ requestMethod: APIRequestMethod, withURL url: URL, headers: [String: String]?, requestBody: [String: Any]?) async -> APIURLResponse<URL, HTTPURLResponse> {
        let request = APIManager(url: url, requestMethod: requestMethod)
        return await request.initializeDownloadRequest(with: headers, and: requestBody)
    }
    
}
