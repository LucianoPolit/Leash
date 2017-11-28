//
//  MockSerializationInterceptor.swift
//  Example
//
//  Created by Luciano Polit on 11/28/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Alamofire
@testable import Leash

class MockSerializationInterceptor<U>: SerializationInterceptor {
    
    var completion: ((InterceptorChain<U>?) -> ())?
    
    init(completion: ((InterceptorChain<U>?) -> ())? = nil) {
        self.completion = completion
    }
    
    var interceptCalled = false
    var interceptParameterChain: InterceptorChain<U>?
    var interceptParameterResult: Result<U>?
    
    func intercept<T>(chain: InterceptorChain<T.SerializedObject>,
                      result: Result<T.SerializedObject>,
                      serializer: T) where T : DataResponseSerializerProtocol {
        interceptCalled = true
        interceptParameterChain = chain as? InterceptorChain<U>
        interceptParameterResult = result as? Result<U>
        completion?(interceptParameterChain)
    }
    
}
