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

class BodyValidator: SuccessInterceptor {
    
    func intercept<T>(chain: InterceptorChain<T>, response: DefaultDataResponse) {
        defer { chain.proceed() }
        guard let data = response.data else { return }
        
        if let error = try? chain.manager.jsonDecoder.decode(APIError.self, from: data) {
            chain.complete(with: Error.server(error))
        }
    }
    
}
