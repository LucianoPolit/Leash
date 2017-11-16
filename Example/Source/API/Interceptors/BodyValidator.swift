//
//  BodyValidator.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash
import Alamofire

/// Interceptor responsible for validating the body.
/// In some cases, the body may contain an API error with extra information.
/// In case that an API error is found, the interception is completed with it.
class BodyValidator: SuccessInterceptor {
    
    func intercept<T>(chain: InterceptorChain<T>, response: DefaultDataResponse) {
        defer { chain.proceed() }
        guard let data = response.data else { return }
        
        if let error = try? chain.manager.jsonDecoder.decode(APIError.self, from: data) {
            chain.complete(with: Error.server(error))
        }
    }
    
}
