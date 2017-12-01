//
//  Client.swift
//  Example
//
//  Created by Luciano Polit on 11/19/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash

class Client<Target: Endpoint>: Leash.Client {
    
    @discardableResult
    func execute<T: Decodable>(_ endpoint: Target, completion: @escaping (Response<T>) -> ()) -> DataRequest? {
        return super.execute(endpoint, completion: completion)
    }
    
    override func urlRequest(for endpoint: Leash.Endpoint) throws -> URLRequest {
        var request = try super.urlRequest(for: endpoint)
        request.setValue("SomeKey", forHTTPHeaderField: "API-KEY")
        return request
    }
    
}
