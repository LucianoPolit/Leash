//
//  MockFailureInterceptor.swift
//  Example
//
//  Created by Luciano Polit on 11/13/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
@testable import Leash

class MockFailureInterceptor<U>: FailureInterceptor {
    
    var interceptCalled = false
    var interceptParameterChain: InterceptorChain<U>?
    var interceptParameterError: Swift.Error?
    
    func intercept<T>(chain: InterceptorChain<T>, error: Swift.Error) {
        interceptCalled = true
        interceptParameterChain = chain as? InterceptorChain<U>
        interceptParameterError = error
    }
    
}
