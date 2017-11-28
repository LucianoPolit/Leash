//
//  MockSuccessInterceptor.swift
//  Example
//
//  Created by Luciano Polit on 11/13/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
@testable import Leash

class MockSuccessInterceptor: SuccessInterceptor {
    
    var completion: ((InterceptorChain<Data>?) -> ())?
    
    init(completion: ((InterceptorChain<Data>?) -> ())? = nil) {
        self.completion = completion
    }
    
    var interceptCalled = false
    var interceptParameterChain: InterceptorChain<Data>?
    var interceptParameterResponse: HTTPURLResponse?
    var interceptParameterData: Data?
    
    func intercept(chain: InterceptorChain<Data>, response: HTTPURLResponse, data: Data) {
        interceptCalled = true
        interceptParameterChain = chain
        interceptParameterResponse = response
        interceptParameterData = data
        completion?(chain)
    }
    
}
