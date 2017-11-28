//
//  BodyValidator.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash

/// Interceptor responsible for validating the body.
/// In some cases, the body may contain an API error with extra information.
/// In case that an API error is found, the interception is completed with it.
class BodyValidator: SuccessInterceptor {
    
    func intercept(chain: InterceptorChain<Data>, response: HTTPURLResponse, data: Data) {
        defer { chain.proceed() }
        
        if let error = try? chain.client.manager.jsonDecoder.decode(APIError.self, from: data) {
            chain.complete(with: Error.server(error))
        }
    }
    
}
