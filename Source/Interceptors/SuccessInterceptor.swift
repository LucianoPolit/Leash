//
//  SuccessInterceptor.swift
//  Pods-Example
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation
import Alamofire

public protocol SuccessInterceptor {
    func intercept<T>(chain: InterceptorChain<T>, response: DefaultDataResponse)
}
