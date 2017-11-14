//
//  InterceptorChain.swift
//  Pods-Example
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation
import Alamofire

typealias InterceptorCompletion<T> = ((response: Response<T>, finish: Bool)?) -> ()

public class InterceptorChain<T> {
    public let manager: Manager
    public let endpoint: Endpoint
    public let request: DataRequest
    private let completion: InterceptorCompletion<T>
    private var completed = false
    
    init(manager: Manager, endpoint: Endpoint, request: DataRequest, completion: @escaping InterceptorCompletion<T>) {
        self.manager = manager
        self.endpoint = endpoint
        self.request = request
        self.completion = completion
    }
}

extension InterceptorChain {
    
    public func proceed() {
        complete(nil)
    }
    
    public func complete(with response: Response<T>, finish: Bool = true) {
        complete((response, finish))
    }
    
    public func complete(with value: T, extra: Any?, finish: Bool = true) {
        complete(with: .success(value: value, extra: extra), finish: finish)
    }
    
    public func complete(with error: Swift.Error, finish: Bool = true) {
        complete(with: .failure(error), finish: finish)
    }
    
    private func complete(_ tuple: (Response<T>, Bool)?) {
        guard !completed else { return }
        completed = true
        completion(tuple)
    }
    
}
