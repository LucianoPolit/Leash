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
class LoggerInterceptor: ExecutionInterceptor, CompletionInterceptor, SerializationInterceptor {
    
    // MARK: - ExecutionInterceptor
    
    func intercept(chain: InterceptorChain<Data>) {
        defer { chain.proceed() }
        guard let request = chain.request.request,
            let method = request.httpMethod,
            let url = request.url?.absoluteString else { return }
        
        Logger.shared.logDebug("👉👉👉 \(method) \(url)")
    }
    
    // MARK: - CompletionInterceptor
    
    func intercept(chain: InterceptorChain<Data>, response: Response<Data>) {
        defer { chain.proceed() }
        guard let request = chain.request.request,
            let method = request.httpMethod,
            let url = request.url?.absoluteString else { return }
        
        switch(response) {
        case .success:
            Logger.shared.logDebug("✔✔✔ \(method) \(url)")
        case .failure(let error):
            Logger.shared.logDebug("✖✖✖ \(method) \(url)")
            Logger.shared.logError(error)
        }
    }
    
    // MARK: - SerializationInterceptor
    
    func intercept<T: DataResponseSerializerProtocol>(chain: InterceptorChain<T.SerializedObject>,
                                                      response: Response<Data>,
                                                      result: Result<T.SerializedObject>,
                                                      serializer: T) {
        defer { chain.proceed() }
        guard let request = chain.request.request,
            let method = request.httpMethod,
            let url = request.url?.absoluteString else { return }
        
        switch(result) {
        case .success:
            Logger.shared.logDebug("✔✔✔ \(method) \(url) (Serialization)")
        case .failure(let error):
            guard case Leash.Error.decoding = error else { return }
            Logger.shared.logDebug("✖✖✖ \(method) \(url) (Serialization)")
            Logger.shared.logError(error)
        }
    }
    
}
