//
//  MockSerializationInterceptor.swift
//  Example
//
//  Created by Luciano Polit on 11/28/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
@testable import Leash

class MockSerializationInterceptor<U>: SerializationInterceptor {
    
    var completion: ((InterceptorChain<U>?) -> ())?
    
    init(completion: ((InterceptorChain<U>?) -> ())? = nil) {
        self.completion = completion
    }
    
    var interceptCalled = false
    var interceptParameterChain: InterceptorChain<U>?
    var interceptParameterResponse: Response<Data>?
    var interceptParameterResult: Result<U, Swift.Error>?
    
    func intercept<T: DataResponseSerializerProtocol>(chain: InterceptorChain<T.SerializedObject>,
                                                      response: Response<Data>,
                                                      result: Result<T.SerializedObject, Swift.Error>,
                                                      serializer: T) {
        interceptCalled = true
        interceptParameterChain = chain as? InterceptorChain<U>
        interceptParameterResponse = response
        interceptParameterResult = result as? Result<U, Swift.Error>
        completion?(interceptParameterChain)
    }
    
}
