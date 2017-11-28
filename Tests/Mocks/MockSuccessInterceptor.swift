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
    
    var completion: ((InterceptorChain?) -> ())?
    
    init(completion: ((InterceptorChain?) -> ())? = nil) {
        self.completion = completion
    }
    
    var interceptCalled = false
    var interceptParameterChain: InterceptorChain?
    var interceptParameterResponse: HTTPURLResponse?
    var interceptParameterData: Data?
    
    func intercept(chain: InterceptorChain, response: HTTPURLResponse, data: Data) {
        interceptCalled = true
        interceptParameterChain = chain
        interceptParameterResponse = response
        interceptParameterData = data
        completion?(chain)
    }
    
}
