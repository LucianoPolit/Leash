//
//  Alamofire+Leash.swift
//  Alamofire
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation
import Alamofire

extension DataRequest {
    
    public func response<T: Decodable>(_ leash: Leash, _ endpoint: Endpoint, _ completion: @escaping (Response<T>) -> Void) {
        let preCompletion = { (response: Response<T>) in
            let interceptions: Leash.Interceptions<T> = leash.completionInterceptions(endpoint: endpoint, request: self, response: response)
            InterceptorsExecutor(queue: interceptions, completion: completion) { $0(response) }
        }
        
        let interceptions: Leash.Interceptions<T> = leash.executionInterceptions(endpoint: endpoint, request: self)
        InterceptorsExecutor(queue: interceptions, completion: preCompletion) { [weak self] callback in
            guard let `self` = self else { return }
            self.response { response in
                if let error = response.error {
                    let interceptions: Leash.Interceptions<T> = leash.failureInterceptions(endpoint: endpoint, request: self, error: error)
                    InterceptorsExecutor(queue: interceptions, completion: callback) { $0(.failure(error)) }
                } else {
                    let interceptions: Leash.Interceptions<T> = leash.successInterceptions(endpoint: endpoint, request: self, response: response)
                    InterceptorsExecutor(queue: interceptions, completion: callback) { $0(response.decoded(with: leash.jsonDecoder)) }
                }
            }
            self.resume()
        }
    }
    
}

private extension DefaultDataResponse {
    
    func decoded<T: Decodable>(with jsonDecoder: JSONDecoder) -> Response<T> {
        guard let data = data else { return .failure(Error.dataUnavailable) }
        
        do {
            let value = try jsonDecoder.decode(T.self, from: data)
            return .success(value, extra: nil)
        } catch {
            return .failure(Error.decoding(error))
        }
    }
    
}

private extension Leash {
    
    typealias Interceptions<T> = [(@escaping InterceptorCompletion<T>) -> ()]
    
    func executionInterceptions<T>(endpoint: Endpoint, request: DataRequest) -> Interceptions<T> {
        return executionInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(leash: self, endpoint: endpoint, request: request, completion: completion)
                interceptor.intercept(chain: chain)
            }
        }
    }
    
    func failureInterceptions<T>(endpoint: Endpoint, request: DataRequest, error: Swift.Error) -> Interceptions<T> {
        return failureInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(leash: self, endpoint: endpoint, request: request, completion: completion)
                interceptor.intercept(chain: chain, error: error)
            }
        }
    }
    
    func successInterceptions<T>(endpoint: Endpoint, request: DataRequest, response: DefaultDataResponse) -> Interceptions<T> {
        return successInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(leash: self, endpoint: endpoint, request: request, completion: completion)
                interceptor.intercept(chain: chain, response: response)
            }
        }
    }
    
    func completionInterceptions<T>(endpoint: Endpoint, request: DataRequest, response: Response<T>) -> Interceptions<T> {
        return completionInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(leash: self, endpoint: endpoint, request: request, completion: completion)
                interceptor.intercept(chain: chain, response: response)
            }
        }
    }
    
}
