//
//  APIEndpoint.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash
import Alamofire

/// Endpoints of the API that can be reached.
/// It contains all the information needed to create the requests.
enum APIEndpoint: Endpoint {
    
    case getExpenses
    case createExpense(CreateExpenseRequest)
    case updateExpense(UpdateExpenseRequest)
    case deleteExpense(String)
    
}

// MARK: - Path

extension APIEndpoint {
    
    var path: String {
        return pathByReplacingParamenters(basePath, parameters: pathParameters)
    }
    
    var basePath: String {
        switch self {
            
        case .getExpenses: return "/expenses/"
        case .createExpense: return "/expenses/"
        case .updateExpense: return "/expenses/{id}/"
        case .deleteExpense: return "/expenses/{id}/"
            
        }
    }
    
    var pathParameters: [String: CustomStringConvertible]? {
        switch self {
            
        case .getExpenses: return nil
        case .createExpense: return nil
        case .updateExpense(let request): return ["{id}": request.id]
        case .deleteExpense(let id): return ["{id}": id]
            
        }
    }
    
}

// MARK: - Method

extension APIEndpoint {
    
    var method: HTTPMethod {
        switch self {
            
        case .getExpenses: return .get
        case .createExpense: return .post
        case .updateExpense: return .put
        case .deleteExpense: return .delete
            
        }
    }
    
}

// MARK: - Parameters

extension APIEndpoint {
    
    var parameters: Any? {
        switch self {
            
        case .getExpenses: return nil
        case .createExpense(let request): return request
        case .updateExpense(let request): return request
        case .deleteExpense: return nil
            
        }
    }
    
}

// MARK: - Utils

private extension APIEndpoint {
    
    func pathByReplacingParamenters(_ path: String, parameters: [String: CustomStringConvertible]?) -> String {
        guard let parameters = parameters else {
            return path
        }
        
        var finalPath = path
        
        for (parameter, value) in parameters {
            finalPath = finalPath.replacingOccurrences(of: parameter, with: "\(value)")
        }
        
        return finalPath
    }
    
}
