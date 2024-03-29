//
//  APIUtils.swift
//
//
//  Created by Abilash S on 10/03/24.
//

import Foundation

public enum APIRequestMethod: String {
    
    case GET
    case POST
    case PATCH
    case PUT
    case DELETE
    // TODO: Is this needed?
    case UNDEFINED
    
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
    public static let internalError = "INTERNAL_ERROR"
    public static let invalidOperation = "INVALID_OPERATION"
    public static let noInternetConnection = "NO_INTERNET_CONNECTION"
    public static let requestTimeout = "REQUEST_TIMEOUT"
    public static let networkConnectionLost = "NETWORK_CONNECTION_LOST"
    public static let hostNotFound = "HOST_NOT_FOUND"
    public static let cannotConnectToHost = "CANNOT_CONNECT_TO_HOST"
    public static let responseNil = "RESPONSE_NIL"
    public static let urlNotFound = "URL_NOT_FOUND"
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
