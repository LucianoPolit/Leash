//
//  MockSuccessInterceptor.swift
//  Example
//
//  Created by Luciano Polit on 11/13/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Alamofire
@testable import Leash

class MockSuccessInterceptor<U: Decodable>: SuccessInterceptor {
    
    var completion: ((InterceptorChain<U>?) -> ())?
    
    init(completion: ((InterceptorChain<U>?) -> ())? = nil) {
        self.completion = completion
    }
    
    var interceptCalled = false
    var interceptParameterChain: InterceptorChain<U>?
    var interceptParameterResponse: DefaultDataResponse?
    
    func intercept<T>(chain: InterceptorChain<T>, response: DefaultDataResponse) {
        interceptCalled = true
        interceptParameterChain = chain as? InterceptorChain<U>
        interceptParameterResponse = response
        completion?(chain as? InterceptorChain<U>)
    }
    
}
