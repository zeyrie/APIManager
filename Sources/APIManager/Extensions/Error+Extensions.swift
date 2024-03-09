//
//  Error+Extensions.swift
//  
//
//  Created by Abilash S on 10/03/24.
//

import Foundation

extension Error {
    var code: Int {
        (self as NSError).code
    }
    
    var description: String {
        (self as NSError).description
    }
    
    var APIErrorInfo: (code: String, message: String, info: Dictionary<String, Any>?)? {
        guard let error = self as? APINetworkError else {
            return nil
        }
        switch error {
            
        case .unAutherizationError(status: let status, message: let message, info: let info):
            return (status, message, info)
        case .invalidError(status: let status, message: let message, info: let info):
            return (status, message, info)
        case .processingError(status: let status, message: let message, info: let info):
            return (status, message, info)
        case .networkError(status: let status, message: let message, info: let info):
            return (status, message, info)
        case .apiManagerError(status: let status, message: let message, info: let info):
            return (status, message, info)
        }
    }
}
