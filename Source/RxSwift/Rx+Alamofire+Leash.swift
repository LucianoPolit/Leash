//
//  Rx+Alamofire+Leash.swift
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
import RxSwift

// MARK: - Reactive

extension DataRequest: ReactiveCompatible { }

extension Reactive where Base: DataRequest {
    
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
    /// - Parameter type: The type on which the response has to be serialized.
    /// - Parameter serializer: The serializer responsible for serializing the request, response and data.
    ///
    /// - Returns: A single with the response.
    public func response<T: DataResponseSerializerProtocol>(queue: DispatchQueue? = nil,
                                                            client: Client,
                                                            endpoint: Endpoint,
                                                            type: T.SerializedObject.Type = T.SerializedObject.self,
                                                            serializer: T) -> Single<ReactiveResponse<T.SerializedObject>> {
        return base.response(queue: queue, client: client, endpoint: endpoint, serializer: serializer)
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
    /// - Parameter type: The type on which the response has to be decoded.
    ///
    /// - Returns: A single with the response.
    public func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil,
                                                client: Client,
                                                endpoint: Endpoint,
                                                type: T.Type = T.self) -> Single<ReactiveResponse<T>> {
        return base.responseDecodable(queue: queue, client: client, endpoint: endpoint)
    }
    
}

// MARK: - Utils

private extension DataRequest {
    
    func response<T: DataResponseSerializerProtocol>(queue: DispatchQueue? = nil,
                                                     client: Client,
                                                     endpoint: Endpoint,
                                                     serializer: T) -> Single<ReactiveResponse<T.SerializedObject>> {
        return Single.create { single in
            self.response(queue: queue, client: client, endpoint: endpoint, serializer: serializer) { response in
                single(SingleEvent.fromResponse(response))
            }
            
            return Disposables.create { }
        }
    }
    
    func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil,
                                         client: Client,
                                         endpoint: Endpoint) -> Single<ReactiveResponse<T>> {
        return response(queue: queue,
                        client: client,
                        endpoint: endpoint,
                        serializer: DataRequest.decodableResponseSerializer(jsonDecoder: client.manager.jsonDecoder))
    }
    
}

private extension SingleEvent {
    
    static func fromResponse(_ response: Response<Element>) -> SingleEvent<ReactiveResponse<Element>> {
        switch response {
        case .success(let value, let extra):
            return .success(ReactiveResponse(value, extra))
        case .failure(let error):
            return .error(error)
        }
    }
    
}
