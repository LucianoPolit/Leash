//
//  ResponseValidator.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash

/// Interceptor responsible for validating the response.
/// In case that the status code is matched to a known error, the interception is completed with it.
class ResponseValidator: SuccessInterceptor {
    
    func intercept(
        chain: InterceptorChain<Data>,
        response: HTTPURLResponse,
        data: Data
    ) {
        defer { chain.proceed() }
        
        let error: Error
        
        switch response.statusCode {
        case 200...299: return
        case 401, 403: error = .unauthorized
        default: error = .unknown
        }
        
        chain.complete(with: error)
    }
    
}
