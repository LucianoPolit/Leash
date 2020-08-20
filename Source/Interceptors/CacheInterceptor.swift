//
//  CacheInterceptor.swift
//
//  Copyright (c) 2017-2020 Luciano Polit <lucianopolit@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
#if !COCOAPODS
import Leash
#endif

public struct CacheExtra { }

public protocol DataStore {
    func data(
        for endpoint: Endpoint
    ) -> Data?
    func save(
        _ data: Data,
        for endpoint: Endpoint
    )
}

open class CacheInterceptor {
    
    public let dataStore: DataStore
    public private(set) var policies: [String: CachePolicyProtocol] = [:]
    
    public init(
        dataStore: DataStore
    ) {
        self.dataStore = dataStore
    }
    
    @discardableResult
    public func register(
        policy: CachePolicyProtocol,
        to path: String
    ) -> Self {
        policies[path] = policy
        return self
    }
    
    open func shouldCache(
        endpoint: Endpoint
    ) -> Bool {
        return endpoint.method == .get
    }
    
    open func policy(
        for endpoint: Endpoint
    ) -> CachePolicyProtocol? {
        guard
            shouldCache(
                endpoint: endpoint
            )
            else { return nil }
        for (path, policy) in policies {
            if path.toRegexValidator()(endpoint.path) {
                return policy
            }
        }
        return nil
    }
    
}

extension CacheInterceptor: ExecutionInterceptor {
    
    public func intercept(
        chain: InterceptorChain<Data>
    ) {
        defer { chain.proceed() }
        guard let policy = policy(for: chain.endpoint),
            policy.shouldCacheBeforeExecution(),
            let data = dataStore.data(for: chain.endpoint)
            else { return }
        chain.complete(
            with: data,
            extra: CacheExtra(),
            finish: policy.shouldFinishAfterCache()
        )
    }
    
}

extension CacheInterceptor: CompletionInterceptor {
    
    public func intercept(
        chain: InterceptorChain<Data>,
        response: Response<Data>
    ) {
        defer { chain.proceed() }
        guard let policy = policy(for: chain.endpoint),
            let error = response.error,
            policy.shouldCacheOnError(error),
            let data = dataStore.data(for: chain.endpoint)
            else { return }
        chain.complete(
            with: data,
            extra: CacheExtra(),
            finish: policy.shouldFinishAfterCache()
        )
    }
    
}

extension CacheInterceptor: SerializationInterceptor {
    
    public func intercept<T: DataResponseSerializerProtocol>(
        chain: InterceptorChain<T.SerializedObject>,
        response: Response<Data>,
        result: Result<T.SerializedObject, Swift.Error>,
        serializer: T
    ) {
        defer { chain.proceed() }
        guard let policy = policy(for: chain.endpoint),
            let value = response.value,
            !(response.extra is CacheExtra),
            (try? result.get()) != nil,
            policy.shouldSaveAfterSuccess()
            else { return }
        dataStore.save(value, for: chain.endpoint)
    }
    
}

private extension String {
    
    func toRegexValidator() -> (String) -> Bool {
        return {
            NSPredicate(
                format: "SELF MATCHES %@",
                self
            ).evaluate(with: $0)
        }
    }
    
}
