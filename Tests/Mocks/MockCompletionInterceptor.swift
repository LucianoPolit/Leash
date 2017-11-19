//
//  MockCompletionInterceptor.swift
//  Example
//
//  Created by Luciano Polit on 11/13/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
@testable import Leash

class MockCompletionInterceptor<U: Decodable>: CompletionInterceptor {
    
    var completion: ((InterceptorChain<U>?) -> ())?
    
    init(completion: ((InterceptorChain<U>?) -> ())? = nil) {
        self.completion = completion
    }
    
    var interceptCalled = false
    var interceptParameterChain: InterceptorChain<U>?
    var interceptParameterResponse: Response<U>?
    
    func intercept<T>(chain: InterceptorChain<T>, response: Response<T>) {
        interceptCalled = true
        interceptParameterChain = chain as? InterceptorChain<U>
        interceptParameterResponse = response as? Response<U>
        completion?(chain as? InterceptorChain<U>)
    }
    
}
