//
//  Client.swift
//  Example
//
//  Created by Luciano Polit on 11/19/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash
import RxSwift

protocol Targetable {
    associatedtype Target: Endpoint
}

class Client<T: Endpoint>: Leash.Client, Targetable {
    
    typealias Target = T
    
    override func urlRequest(for endpoint: Leash.Endpoint) throws -> URLRequest {
        var request = try super.urlRequest(for: endpoint)
        request.setValue("SomeKey", forHTTPHeaderField: "API-KEY")
        return request
    }
    
}

extension Client {
    
    @discardableResult
    func execute<T: Decodable>(_ endpoint: Target, completion: @escaping (Response<T>) -> ()) -> DataRequest? {
        return execute(endpoint as Leash.Endpoint, completion: completion)
    }
    
}

extension Reactive where Base: Leash.Client & Targetable {
    
    func execute<T: Decodable>(_ endpoint: Base.Target) -> Single<T> {
        return execute(endpoint as Leash.Endpoint)
    }
    
}
