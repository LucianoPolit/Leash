//
//  LoggerInterceptor.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash

/// Interceptor responsible for logging the requests and responses.
class LoggerInterceptor: ExecutionInterceptor, CompletionInterceptor {
    
    // MARK: - ExecutionInterceptor
    
    func intercept<T>(chain: InterceptorChain<T>) {
        defer { chain.proceed() }
        guard let request = chain.request.request,
            let method = request.httpMethod,
            let url = request.url?.absoluteString else { return }
        
        Logger.shared.logDebug("👉👉👉 \(method) \(url)")
    }
    
    // MARK: - CompletionInterceptor
    
    func intercept<T>(chain: InterceptorChain<T>, response: Response<T>) {
        defer { chain.proceed() }
        guard let request = chain.request.request,
            let method = request.httpMethod,
            let url = request.url?.absoluteString else { return }
        
        switch(response) {
        case .success(_):
            Logger.shared.logDebug("✔✔✔ \(method) \(url)")
        case .failure(let error):
            Logger.shared.logDebug("✖✖✖ \(method) \(url)")
            Logger.shared.logError(error)
        }
    }
    
}
