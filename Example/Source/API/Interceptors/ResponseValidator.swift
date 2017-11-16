//
//  ResponseValidator.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash
import Alamofire

/// Interceptor responsible for validating the response.
/// In case that the status code is matched to a known error, the interception is completed with it.
class ResponseValidator: SuccessInterceptor {
    
    func intercept<T>(chain: InterceptorChain<T>, response: DefaultDataResponse) {
        defer { chain.proceed() }
        guard let statusCode = response.response?.statusCode else { return }
        
        let error: Error
        
        switch statusCode {
        case 200...299: return
        case 401, 403: error = .unauthorized
        default: error = .unknown
        }
        
        chain.complete(with: error)
    }
    
}
