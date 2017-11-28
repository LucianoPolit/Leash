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
    
    var completion: ((InterceptorChain?) -> ())?
    
    init(completion: ((InterceptorChain?) -> ())? = nil) {
        self.completion = completion
    }
    
    var interceptCalled = false
    var interceptParameterChain: InterceptorChain?
    
    func intercept(chain: InterceptorChain) {
        interceptCalled = true
        interceptParameterChain = chain
        completion?(chain)
    }
    
}
