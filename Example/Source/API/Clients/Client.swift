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
    
    override func urlRequest(
        for endpoint: Leash.Endpoint
    ) throws -> URLRequest {
        var request = try super.urlRequest(for: endpoint)
        request.setValue(
            "SomeKey",
            forHTTPHeaderField: "API-KEY"
        )
        return request
    }
    
}

extension Client {
    
    @discardableResult
    func execute<T: Decodable>(
        _ endpoint: Target,
        completion: @escaping APICompletion<T>
    ) -> DataRequest? {
        return execute(
            endpoint as Leash.Endpoint,
            completion: completion
        )
    }
    
}

extension Reactive where Base: Leash.Client {
    
    func execute<T: Decodable>(
        _ execution: @escaping (@escaping APICompletion<T>) -> Void
    ) -> Observable<T> {
        return Observable.create { observer in
            execution { response in
                observer.on(
                    Event.fromResponse(response)
                )
            }
            
            return Disposables.create { }
        }
    }
    
    func execute<T: Decodable, U>(
        _ execution: @escaping (U, @escaping APICompletion<T>) -> Void,
        with request: U
    ) -> Observable<T> {
        return Observable.create { observer in
            execution(request) { response in
                observer.on(
                    Event.fromResponse(response)
                )
            }
            
            return Disposables.create { }
        }
    }
    
}

private extension Event {
    
    static func fromResponse(
        _ response: APIResponse<Element>
    ) -> Event<Element> {
        switch response {
        case .success(let value):
            return .next(value)
        case .failure(let error):
            return .error(error)
        }
    }
    
}
