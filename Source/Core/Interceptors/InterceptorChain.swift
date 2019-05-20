//
//  InterceptorChain.swift
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

/// Completion handler of the interception.
typealias InterceptorCompletion<T> = ((response: Response<T>, finish: Bool)?) -> ()

/// Contains all the information that an interceptor might require.
open class InterceptorChain<T> {
    
    /// The client that is requesting the interception.
    public let client: Client
    /// The endpoint that is being intercepted.
    public let endpoint: Endpoint
    /// The request that is being intercepted.
    public let request: DataRequest
    /// The completion handler of the interception.
    fileprivate let completion: InterceptorCompletion<T>
    /// Determines if the interception is completed or not.
    fileprivate var completed = false
    
    /// Initializes and returns a newly allocated object with the specified parameters.
    init(client: Client, endpoint: Endpoint, request: DataRequest, completion: @escaping InterceptorCompletion<T>) {
        self.client = client
        self.endpoint = endpoint
        self.request = request
        self.completion = completion
    }
    
}

extension InterceptorChain {
    
    /// Completes the interception without injecting any response.
    public func proceed() {
        complete(nil)
    }
    
    /// Completes the interception injecting the specified response.
    ///
    /// - Parameter response: The response that is being injected.
    /// - Parameter finish: Determines if the process should be finished or not.
    ///                     In case that it is false, the completion handler will receive multiple calls.
    public func complete(with response: Response<T>, finish: Bool = true) {
        complete((response, finish))
    }
    
    /// Completes the interception injecting a successful response with the specified parameters.
    ///
    /// - Parameter value: The value of the response.
    /// - Parameter extra: Any extra information can be specified.
    ///                    The purpose of this parameter is to be used by another interceptor or by the completion handler.
    /// - Parameter finish: Determines if the process should be finished or not.
    ///                     In case that it is false, the completion handler will receive multiple calls.
    public func complete(with value: T, extra: Any? = nil, finish: Bool = true) {
        complete(with: .success(value: value, extra: extra), finish: finish)
    }
    
    /// Completes the interception injecting a failed response with the specified error.
    ///
    /// - Parameter error: The error of the response.
    /// - Parameter finish: Determines if the process should be finished or not.
    ///                     In case that it is false, the completion handler will receive multiple calls.
    public func complete(with error: Swift.Error, finish: Bool = true) {
        complete(with: .failure(error), finish: finish)
    }
    
    /// Completes the interception with the specified tuple.
    private func complete(_ tuple: (Response<T>, Bool)?) {
        guard !completed else { return }
        completed = true
        completion(tuple)
    }
    
}

extension InterceptorChain where T == Data {
    
    /// Retries the operation with the same completion handler.
    ///
    /// - Returns: The new request.
    @discardableResult
    public func retry() throws -> DataRequest {
        let request = try client.request(for: endpoint)
        return request.response(client: client, endpoint: endpoint) { response in
            self.complete(with: response)
        }
    }
    
}
