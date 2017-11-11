//
//  ExecutionInterceptor.swift
//  Pods-Example
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation

public protocol ExecutionInterceptor {
    func intercept<T>(chain: InterceptorChain<T>)
}
