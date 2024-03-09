//
//  APIUtils.swift
//
//
//  Created by Abilash S on 10/03/24.
//

import Foundation

public enum APIRequestMethod: String {
    
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
    // TODO: Is this needed?
    case undefined = "UNDEFINED"
    
}

public enum APIURLResponse<Data: Any, Response: HTTPURLResponse> {
    case success(Data, Response)
    case failure(APINetworkError)
    
    public func resolve() throws -> (data: Data, response: Response) {
        switch self {
        case .success(let data, let response):
            return (data, response)
        case .failure(let error):
            throw error
        }
    }
    
}

public enum APINetworkError: Error {
    case unAutherizationError(status: String, message: String, info: Dictionary<String, Any>?)
    case invalidError(status: String, message: String, info: Dictionary<String, Any>?)
    case processingError(status: String, message: String, info: Dictionary<String, Any>?)
    case networkError(status: String, message: String, info: Dictionary<String, Any>?)
    case apiManagerError(status: String, message: String, info: Dictionary<String, Any>?)
}

public enum APIErrorStatus {
    static let internalError = "INTERNAL_ERROR"
    static let invalidOperation = "INVALID_OPERATION"
    static let noInternetConnection = "NO_INTERNET_CONNECTION"
    static let requestTimeout = "REQUEST_TIMEOUT"
    static let networkConnectionLost = "NETWORK_CONNECTION_LOST"
    static let hostNotFound = "HOST_NOT_FOUND"
    static let cannotConnectToHost = "CANNOT_CONNECT_TO_HOST"
    static let responseNil = "RESPONSE_NIL"
    static let urlNotFound = "URL_NOT_FOUND"
}

func convertURLSessionErrorToAPIError(_ error: Error) -> APINetworkError {
    if let apiError = error as? APINetworkError {
        return apiError
    } else {
        switch error.code {
        case NSURLErrorDataNotAllowed, NSURLErrorNotConnectedToInternet:
            return APINetworkError.networkError(status: APIErrorStatus.noInternetConnection, message: error.localizedDescription, info: nil)
        case NSURLErrorTimedOut:
            return APINetworkError.networkError(status: APIErrorStatus.requestTimeout, message: error.localizedDescription, info: nil)
        case NSURLErrorNetworkConnectionLost:
            return APINetworkError.networkError(status: APIErrorStatus.networkConnectionLost, message: error.localizedDescription, info: nil)
        case NSURLErrorCannotFindHost:
            return APINetworkError.networkError(status: APIErrorStatus.hostNotFound, message: error.localizedDescription, info: nil)
        case NSURLErrorCannotConnectToHost:
            return APINetworkError.networkError(status: APIErrorStatus.cannotConnectToHost, message: error.localizedDescription, info: nil)
        default:
            return APINetworkError.apiManagerError(status: APIErrorStatus.internalError, message: error.description, info: nil)
        }
    }
    
}
