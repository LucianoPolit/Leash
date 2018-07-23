//
//  Alamofire+Leash.swift
//
//  Copyright (c) 2017-2018 Luciano Polit <lucianopolit@gmail.com>
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

/// Specific type of `Request` that manages an underlying `URLSessionDataTask`.
public typealias DataRequest = Alamofire.DataRequest
/// The type in which all data response serializers must conform to in order to serialize a response.
public typealias DataResponseSerializerProtocol = Alamofire.DataResponseSerializerProtocol
/// HTTP method definitions.
public typealias HTTPMethod = Alamofire.HTTPMethod
/// Used to represent whether a request was successful or encountered an error.
public typealias Result = Alamofire.Result
/// Responsible for creating and managing `Request` objects, as well as their underlying `NSURLSession`.
public typealias SessionManager = Alamofire.SessionManager

// MARK: - Data

extension DataRequest {
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// Also, it is responsible for calling the interceptors when needed (all asynchronous and executed in a queue order):
    ///
    /// - Execution: called before the request is executed.
    /// - Failure: called when there is a problem executing the request.
    /// - Success: called when there is no problem executing the request.
    /// - Completion: called before the completion handler.
    ///
    /// Any of the interceptors might have as result to call the completion handler with the specified response.
    /// Moreover, it could finish the operation if it is required.
    ///
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter client: The client that created the request. It also contains the interceptors that must be called.
    /// - Parameter endpoint: The endpoint that was used to create the request.
    /// - Parameter completion: Handler of the response.
    ///
    /// - Returns: The request.
    @discardableResult
    public func response(queue: DispatchQueue? = nil,
                         client: Client,
                         endpoint: Endpoint,
                         completion: @escaping (Response<Data>) -> ()) -> Self {
        let preCompletion = { (response: Response<Data>) in
            client.intercept(.completion(endpoint: endpoint, request: self, response: response),
                             queue: queue,
                             completion: completion) { $0(response) }
        }
        
        let finally = { (callback: @escaping InterceptorsExecutor<Data>.Completion) in
            self.responseData { response in
                if let httpResponse = response.response, let data = response.value, response.error == nil {
                    client.intercept(.success(endpoint: endpoint, request: self, response: httpResponse, data: data),
                                     queue: queue,
                                     completion: callback) { $0(.success(value: data, extra: nil)) }
                } else {
                    let error = response.error ?? Error.unknown
                    client.intercept(.failure(endpoint: endpoint, request: self, error: error),
                                     queue: queue,
                                     completion: callback) { $0(.failure(error)) }
                }
            }
            self.resume()
        }
        
        client.intercept(.execution(endpoint: endpoint, request: self),
                         queue: queue,
                         completion: preCompletion,
                         finally: finally)
        
        return self
    }
    
}

// MARK: - Serializer

extension DataRequest {
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// Also, it is responsible for calling the interceptors when needed (all asynchronous and executed in a queue order):
    ///
    /// - Execution: called before the request is executed.
    /// - Failure: called when there is a problem executing the request.
    /// - Success: called when there is no problem executing the request.
    /// - Completion: called before the completion handler.
    /// - Serialization: called after the serialization operation.
    ///
    /// Any of the interceptors might have as result to call the completion handler with the specified response.
    /// Moreover, it could finish the operation if it is required.
    ///
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter client: The client that created the request. It also contains the interceptors that must be called.
    /// - Parameter endpoint: The endpoint that was used to create the request.
    /// - Parameter serializer: The serializer responsible for serializing the request, response and data.
    /// - Parameter completion: Handler of the response.
    ///
    /// - Returns: The request.
    @discardableResult
    public func response<T: DataResponseSerializerProtocol>(queue: DispatchQueue? = nil,
                                                            client: Client,
                                                            endpoint: Endpoint,
                                                            serializer: T,
                                                            completion: @escaping (Response<T.SerializedObject>) -> ()) -> Self {
        return response(queue: .global(qos: .utility), client: client, endpoint: endpoint) { response in
            let result = serializer.serializeResponse(self.request, self.response, response.value, response.error)
            let interceptions = client.serializationInterceptions(endpoint: endpoint,
                                                                  request: self,
                                                                  response: response,
                                                                  result: result,
                                                                  serializer: serializer)
            client.intercept(interceptions, queue: queue, completion: completion) { callback in
                switch result {
                case .failure(let error):
                    callback(.failure(error))
                case .success(let value):
                    callback(.success(value: value, extra: response.extra))
                }
            }
        }
    }
    
}

// MARK: - Decodable

extension DataRequest {
    
    /// Creates a response serializer that returns a decoded object result type
    /// constructed from the response data using the specified JSON decoder.
    public static func decodableResponseSerializer<T: Decodable>(jsonDecoder: JSONDecoder) -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, _, data, error in
            guard let data = data else { return .failure(error ?? Error.unknown) }
            
            do {
                let value = try jsonDecoder.decode(T.self, from: data)
                return .success(value)
            } catch {
                return .failure(Error.decoding(error))
            }
        }
    }
    
    /// Adds a handler to be called once the request has finished.
    ///
    /// Also, it is responsible for calling the interceptors when needed (all asynchronous and executed in a queue order):
    ///
    /// - Execution: called before the request is executed.
    /// - Failure: called when there is a problem executing the request.
    /// - Success: called when there is no problem executing the request.
    /// - Completion: called before the completion handler.
    /// - Serialization: called after the serialization operation.
    ///
    /// Any of the interceptors might have as result to call the completion handler with the specified response.
    /// Moreover, it could finish the operation if it is required.
    ///
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter client: The client that created the request. It also contains the interceptors that must be called.
    /// - Parameter endpoint: The endpoint that was used to create the request.
    /// - Parameter completion: Handler of the response.
    ///
    /// - Returns: The request.
    @discardableResult
    public func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil,
                                                client: Client,
                                                endpoint: Endpoint,
                                                completion: @escaping (Response<T>) -> ()) -> Self {
        return response(queue: queue,
                        client: client,
                        endpoint: endpoint,
                        serializer: DataRequest.decodableResponseSerializer(jsonDecoder: client.manager.jsonDecoder),
                        completion: completion)
    }
    
}

// MARK: - Utils

private extension Client {
    
    typealias Interception<T> = InterceptorsExecutor<T>.Interception
    
    enum DataInterception {
        case execution(endpoint: Endpoint, request: DataRequest)
        case failure(endpoint: Endpoint, request: DataRequest, error: Swift.Error)
        case success(endpoint: Endpoint, request: DataRequest, response: HTTPURLResponse, data: Data)
        case completion(endpoint: Endpoint, request: DataRequest, response: Response<Data>)
    }
    
}

private extension Client {
    
    func intercept<T>(_ interceptions: [Interception<T>],
                      queue: DispatchQueue?,
                      completion: @escaping InterceptorsExecutor<T>.Completion,
                      finally: @escaping InterceptorsExecutor<T>.Finally) {
        InterceptorsExecutor(queue: queue,
                             interceptions: interceptions,
                             completion: completion,
                             finally: finally)
    }
    
    func intercept(_ type: DataInterception,
                   queue: DispatchQueue?,
                   completion: @escaping InterceptorsExecutor<Data>.Completion,
                   finally: @escaping InterceptorsExecutor<Data>.Finally) {
        intercept(interceptions(of: type),
                  queue: queue,
                  completion: completion,
                  finally: finally)
    }
    
    func interceptions(of type: DataInterception) -> [Interception<Data>] {
        switch type {
        case .execution(let endpoint, let request):
            return executionInterceptions(endpoint: endpoint, request: request)
        case .failure(let endpoint, let request, let error):
            return failureInterceptions(endpoint: endpoint, request: request, error: error)
        case .success(let endpoint, let request, let response, let data):
            return successInterceptions(endpoint: endpoint, request: request, response: response, data: data)
        case .completion(let endpoint, let request, let response):
            return completionInterceptions(endpoint: endpoint, request: request, response: response)
        }
    }
    
}

private extension Client {
    
    func executionInterceptions(endpoint: Endpoint,
                                request: DataRequest) -> [Interception<Data>] {
        return manager.executionInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(client: self, endpoint: endpoint, request: request, completion: completion)
                interceptor.intercept(chain: chain)
            }
        }
    }
    
    func failureInterceptions(endpoint: Endpoint,
                              request: DataRequest,
                              error: Swift.Error) -> [Interception<Data>] {
        return manager.failureInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(client: self, endpoint: endpoint, request: request, completion: completion)
                interceptor.intercept(chain: chain, error: error)
            }
        }
    }
    
    func successInterceptions(endpoint: Endpoint,
                              request: DataRequest,
                              response: HTTPURLResponse,
                              data: Data) -> [Interception<Data>] {
        return manager.successInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(client: self, endpoint: endpoint, request: request, completion: completion)
                interceptor.intercept(chain: chain, response: response, data: data)
            }
        }
    }
    
    func completionInterceptions(endpoint: Endpoint,
                                 request: DataRequest,
                                 response: Response<Data>) -> [Interception<Data>] {
        return manager.completionInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(client: self, endpoint: endpoint, request: request, completion: completion)
                interceptor.intercept(chain: chain, response: response)
            }
        }
    }
    
    func serializationInterceptions<T: DataResponseSerializerProtocol>(endpoint: Endpoint,
                                                                       request: DataRequest,
                                                                       response: Response<Data>,
                                                                       result: Result<T.SerializedObject>,
                                                                       serializer: T) -> [Interception<T.SerializedObject>] {
        return manager.serializationInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(client: self, endpoint: endpoint, request: request, completion: completion)
                interceptor.intercept(chain: chain, response: response, result: result, serializer: serializer)
            }
        }
    }
    
}
