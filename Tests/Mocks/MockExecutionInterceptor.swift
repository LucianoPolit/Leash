//
//  MockExecutionInterceptor.swift
//  Example
//
//  Created by Luciano Polit on 11/13/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
@testable import Leash

class MockExecutionInterceptor<U>: ExecutionInterceptor {
    
    var interceptCalled = false
    var interceptParameterChain: InterceptorChain<U>?
    
    func intercept<T>(chain: InterceptorChain<T>) {
        interceptCalled = true
        interceptParameterChain = chain as? InterceptorChain<U>
    }
    
}
