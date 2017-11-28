//
//  MockFailureInterceptor.swift
//  Example
//
//  Created by Luciano Polit on 11/13/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
@testable import Leash

class MockFailureInterceptor: FailureInterceptor {
    
    var completion: ((InterceptorChain?) -> ())?
    
    init(completion: ((InterceptorChain?) -> ())? = nil) {
        self.completion = completion
    }
    
    var interceptCalled = false
    var interceptParameterChain: InterceptorChain?
    var interceptParameterError: Swift.Error?
    
    func intercept(chain: InterceptorChain, error: Swift.Error) {
        interceptCalled = true
        interceptParameterChain = chain
        interceptParameterError = error
        completion?(chain)
    }
    
}
