//
//  Endpoint.swift
//  Example
//
//  Created by Luciano Polit on 11/14/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
@testable import Leash

struct Endpoint: Leash.Endpoint {
    
    let path: String
    let method: HTTPMethod
    let parameters: Any?
    
    init(path: String = "", method: HTTPMethod = .get, parameters: Any? = nil) {
        self.path = path
        self.method = method
        self.parameters = parameters
    }
    
}
