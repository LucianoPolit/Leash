//
//  MockCompletionInterceptor.swift
//  Example
//
//  Created by Luciano Polit on 11/13/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
@testable import Leash

class MockCompletionInterceptor<U>: CompletionInterceptor {
    
    var interceptCalled = false
    var interceptParameterChain: InterceptorChain<U>?
    var interceptParameterResponse: Response<U>?
    
    func intercept<T>(chain: InterceptorChain<T>, response: Response<T>) {
        interceptCalled = true
        interceptParameterChain = chain as? InterceptorChain<U>
        interceptParameterResponse = response as? Response<U>
    }
    
}
