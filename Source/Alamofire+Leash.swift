//
//  Alamofire+Leash.swift
//
//  Copyright (c) 2017 Luciano Polit <lucianopolit@gmail.com>
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
import Alamofire

extension DataRequest {
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// Also, it is responsible for calling the interceptors when needed (all are asynchronous and executed in a queue order):
    ///
    /// - Execution: called before the request is executed.
    /// - Failure: called when there is a problem executing the request.
    /// - Success: called when there is no problem executing the request.
    /// - Completion: called before the completion handler.
    ///
    /// Any of the interceptors might have as result to call the completion handler with the specified response.
    /// Moreover, it could finish the operation if it is required.
    ///
    /// - Parameter client: The client that created the request. It also contains the interceptors that must be called.
    /// - Parameter endpoint: The endpoint that was used to create the request.
    /// - Parameter completion: Handler of the response.
    ///
    /// - Returns: The request.
    @discardableResult
    public func response<T: Decodable>(_ client: Client, _ endpoint: Endpoint, _ completion: @escaping (Response<T>) -> ()) -> Self {
        let preCompletion = { (response: Response<T>) in
            let interceptions: Client.Interceptions<T> = client.completionInterceptions(endpoint: endpoint, request: self, response: response)
            InterceptorsExecutor(queue: interceptions, completion: completion) { $0(response) }
        }
        
        let interceptions: Client.Interceptions<T> = client.executionInterceptions(endpoint: endpoint, request: self)
        InterceptorsExecutor(queue: interceptions, completion: preCompletion) { [weak self] callback in
            guard let `self` = self else { return }
            
            self.response { response in
                if let error = response.error {
                    let interceptions: Client.Interceptions<T> = client.failureInterceptions(endpoint: endpoint, request: self, error: error)
                    InterceptorsExecutor(queue: interceptions, completion: callback) { $0(.failure(error)) }
                } else {
                    let interceptions: Client.Interceptions<T> = client.successInterceptions(endpoint: endpoint, request: self, response: response)
                    InterceptorsExecutor(queue: interceptions, completion: callback) { $0(response.decoded(with: client.manager.jsonDecoder)) }
                }
            }
            
            self.resume()
        }
        
        return self
    }
    
}

// MARK: - Utils

private extension DefaultDataResponse {
    
    func decoded<T: Decodable>(with jsonDecoder: JSONDecoder) -> Response<T> {
        guard let data = data else { return .failure(Error.unknown) }
        
        do {
            let value = try jsonDecoder.decode(T.self, from: data)
            return .success(value: value, extra: nil)
        } catch {
            return .failure(Error.decoding(error))
        }
    }
    
}

private extension Client {
    
    typealias Interceptions<T> = [(@escaping InterceptorCompletion<T>) -> ()]
    
    func executionInterceptions<T: Decodable>(endpoint: Endpoint, request: DataRequest) -> Interceptions<T> {
        return manager.executionInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(client: self, endpoint: endpoint, request: request, completion: completion)
                interceptor.intercept(chain: chain)
            }
        }
    }
    
    func failureInterceptions<T: Decodable>(endpoint: Endpoint, request: DataRequest, error: Swift.Error) -> Interceptions<T> {
        return manager.failureInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(client: self, endpoint: endpoint, request: request, completion: completion)
                interceptor.intercept(chain: chain, error: error)
            }
        }
    }
    
    func successInterceptions<T: Decodable>(endpoint: Endpoint, request: DataRequest, response: DefaultDataResponse) -> Interceptions<T> {
        return manager.successInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(client: self, endpoint: endpoint, request: request, completion: completion)
                interceptor.intercept(chain: chain, response: response)
            }
        }
    }
    
    func completionInterceptions<T: Decodable>(endpoint: Endpoint, request: DataRequest, response: Response<T>) -> Interceptions<T> {
        return manager.completionInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(client: self, endpoint: endpoint, request: request, completion: completion)
                interceptor.intercept(chain: chain, response: response)
            }
        }
    }
    
}
