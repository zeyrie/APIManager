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
        } catch let error {
            APILogger.shared.error("\(error)")
            return .failure(<#T##APINetworkError#>)
        }
        
    }
    
}
