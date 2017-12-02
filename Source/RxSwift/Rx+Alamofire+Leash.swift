//
//  Rx+Alamofire+Leash.swift
//  Alamofire
//
//  Created by Luciano Polit on 12/1/17.
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
