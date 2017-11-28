//
//  MockExecutionInterceptor.swift
//  Example
//
//  Created by Luciano Polit on 11/13/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
@testable import Leash

class MockExecutionInterceptor: ExecutionInterceptor {
    
    var completion: ((InterceptorChain<Data>?) -> ())?
    
    init(completion: ((InterceptorChain<Data>?) -> ())? = nil) {
        self.completion = completion
    }
    
    var interceptCalled = false
    var interceptParameterChain: InterceptorChain<Data>?
    
    func intercept(chain: InterceptorChain<Data>) {
        interceptCalled = true
        interceptParameterChain = chain
        completion?(chain)
    }
    
}
