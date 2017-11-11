//
//  CompletionInterceptor.swift
//  Pods-Example
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation

public protocol CompletionInterceptor {
    func intercept<T>(chain: InterceptorChain<T>, response: Response<T>)
}
