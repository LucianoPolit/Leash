//
//  Endpoint.swift
//  Example
//
//  Created by Luciano Polit on 11/19/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash

protocol Endpoint: Leash.Endpoint {
    var basePath: String { get }
    var pathParameters: [String: CustomStringConvertible]? { get }
}

extension Endpoint {
    
    var path: String {
        guard let parameters = pathParameters else { return basePath }
        
        var finalPath = basePath
        
        for (parameter, value) in parameters {
            finalPath = finalPath.replacingOccurrences(
                of: parameter,
                with: "\(value)"
            )
        }
        
        return finalPath
    }
    
}
