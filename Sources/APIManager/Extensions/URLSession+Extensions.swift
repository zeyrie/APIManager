//
//  URLSession+Extensions.swift
//  
//
//  Created by Abilash S on 10/03/24.
//

import Foundation

extension URLSession {
    
    func dataTask(with request: URLRequest) async -> APIURLResponse<Data, HTTPURLResponse>  {
        do {
            let (data, response) = try await data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                APILogger.shared.error("\(APIErrorStatus.responseNil) - Response is Nil")
                return .failure(APINetworkError.apiManagerError(status: APIErrorStatus.responseNil, message: "Response is Nil", info: nil))
            }
            return .success(data, httpResponse)
        } catch let error {
            APILogger.shared.error("\(error)")
            return .failure(convertURLSessionErrorToAPIError(error))
        }
    }
    
    func uploadTask(with request: URLRequest, fromFile url: URL) async -> APIURLResponse<Data, HTTPURLResponse> {
        do {
            let (data, response) = try await upload(for: request, fromFile: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                APILogger.shared.error("\(APIErrorStatus.responseNil) - Response is Nil")
                return .failure(APINetworkError.apiManagerError(status: APIErrorStatus.responseNil, message: "Response is Nil", info: nil))
            }
            return .success(data, httpResponse)
        } catch let error {
            APILogger.shared.error("\(error)")
            return .failure(convertURLSessionErrorToAPIError(error))
        }
    }
    
    func downloadTask(with request: URLRequest, completionHandler: @escaping (APIURLResponse<URL, HTTPURLResponse>) -> Void) -> URLSessionDownloadTask {
        return downloadTask(with: request) { (tempURL, response, error) in
            if let error {
                APILogger.shared.error("\(error)")
                completionHandler(.failure(convertURLSessionErrorToAPIError(error)))
                return
            }
            
            guard let url = tempURL else {
                APILogger.shared.error("\(APIErrorStatus.urlNotFound) - Couldn't find downloaded file's URL")
                completionHandler(.failure(APINetworkError.apiManagerError(status: APIErrorStatus.urlNotFound, message: "Couldn't find downloaded file's URL", info: nil)))
                return
            }
            
            guard let urlResponse = response, let httpResponse = urlResponse as? HTTPURLResponse else {
                APILogger.shared.error("\(APIErrorStatus.responseNil) - Response is Nil")
                completionHandler(.failure(APINetworkError.apiManagerError(status: APIErrorStatus.responseNil, message: "Response is Nil", info: nil)))
                return
            }
            
            completionHandler(.success(url, httpResponse))
        }
    }
}
