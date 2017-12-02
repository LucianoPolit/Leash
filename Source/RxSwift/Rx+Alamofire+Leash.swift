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
    
    public func response<T: DataResponseSerializerProtocol>(queue: DispatchQueue? = nil,
                                                            client: Client,
                                                            endpoint: Endpoint,
                                                            serializer: T) -> Single<ReactiveResponse<T.SerializedObject>> {
        return base.response(queue: queue, client: client, endpoint: endpoint, serializer: serializer)
    }
    
    public func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil,
                                                client: Client,
                                                endpoint: Endpoint) -> Single<ReactiveResponse<T>> {
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
