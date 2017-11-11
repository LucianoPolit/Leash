//
//  InterceptorChain.swift
//  Pods-Example
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation
import Alamofire

typealias InterceptorCompletion<T> = ((response: Response<T>, finish: Bool)?) -> ()

public struct InterceptorChain<T> {
    public let leash: Leash
    public let endpoint: Endpoint
    public let request: DataRequest
    let completion: InterceptorCompletion<T>
}

extension InterceptorChain {
    
    func proceed() {
        completion(nil)
    }
    
    func complete(with response: Response<T>, finish: Bool = true) {
        completion((response, finish))
    }
    
    func complete(with value: T, extra: Any?, finish: Bool = true) {
        complete(with: Response.success(value, extra: extra), finish: finish)
    }
    
    func complete(with error: Swift.Error, finish: Bool = true) {
        complete(with: Response.failure(error), finish: finish)
    }
    
}
