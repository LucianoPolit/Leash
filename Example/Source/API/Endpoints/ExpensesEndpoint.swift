//
//  ExpensesEndpoint.swift
//  Example
//
//  Created by Luciano Polit on 11/19/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash

/// Expenses endpoints of the API that can be reached.
/// It contains all the information needed to create the requests.
enum ExpensesEndpoint: Endpoint {
    case readAll
    case create(CreateExpenseRequest)
    case update(UpdateExpenseRequest)
    case delete(String)
}

// MARK: - Path

extension ExpensesEndpoint {
    
    var basePath: String {
        switch self {
        case .readAll: return "/expenses/"
        case .create: return "/expenses/"
        case .update: return "/expenses/{id}/"
        case .delete: return "/expenses/{id}/"
        }
    }
    
    var pathParameters: [String: CustomStringConvertible]? {
        switch self {
        case .readAll: return nil
        case .create: return nil
        case .update(let request): return ["{id}": request.id]
        case .delete(let id): return ["{id}": id]
        }
    }
    
}

// MARK: - Method

extension ExpensesEndpoint {
    
    var method: HTTPMethod {
        switch self {
        case .readAll: return .get
        case .create: return .post
        case .update: return .put
        case .delete: return .delete
        }
    }
    
}

// MARK: - Parameters

extension ExpensesEndpoint {
    
    var parameters: Any? {
        switch self {
        case .readAll: return nil
        case .create(let request): return request
        case .update(let request): return request
        case .delete: return nil
        }
    }
    
}
