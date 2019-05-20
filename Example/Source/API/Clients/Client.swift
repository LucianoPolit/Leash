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

class Client<Target: Endpoint>: Leash.Client, Targetable {
    
    override func urlRequest(for endpoint: Leash.Endpoint) throws -> URLRequest {
        var request = try super.urlRequest(for: endpoint)
        request.setValue("SomeKey", forHTTPHeaderField: "API-KEY")
        return request
    }
    
}

extension Client {
    
    @discardableResult
    func execute<T: Decodable>(_ endpoint: Target, completion: @escaping APICompletion<T>) -> DataRequest? {
        return execute(endpoint as Leash.Endpoint, completion: completion)
    }
    
}

extension Reactive where Base: Leash.Client {
    
    func execute<T: Decodable>(_ execution: @escaping (@escaping APICompletion<T>) -> ()) -> Single<T> {
        return Single.create { single in
            execution { response in
                single(SingleEvent.fromResponse(response))
            }
            
            return Disposables.create { }
        }
    }
    
    func execute<T: Decodable, U>(_ execution: @escaping (U, @escaping APICompletion<T>) -> (), with request: U) -> Single<T> {
        return Single.create { single in
            execution(request) { response in
                single(SingleEvent.fromResponse(response))
            }
            
            return Disposables.create { }
        }
    }
    
}

private extension SingleEvent {
    
    static func fromResponse(_ response: APIResponse<Element>) -> SingleEvent<Element> {
        switch response {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return .error(error)
        }
    }
    
}
