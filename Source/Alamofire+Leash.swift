//
//  Alamofire+Leash.swift
//  Alamofire
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation
import Alamofire

extension DataRequest {
    
    @discardableResult
    public func response<T: Decodable>(_ leash: Leash, _ completion: @escaping (Response<T>) -> Void) -> Self {
        return response { response in
            
        }
    }
    
}

private extension DataResponse {
    
    func decoded<T: Decodable>(with jsonDecoder: JSONDecoder) -> Response<T> {
        guard let data = data else {
            return .failure(error: .dataUnavailable)
        }
        
        do {
            let value = try jsonDecoder.decode(T.self, from: data)
            return .success(value: value, extra: nil)
        } catch {
            return .failure(error: .decoding(error))
        }
    }
    
}

private extension Leash {
    
    func executionInterceptors<T>(router: Router,
                                  request: DataRequest) -> [(@escaping InterceptorCompletion<T>) -> ()] {
        return executionInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(leash: self, router: router, request: request, completion: completion)
                interceptor.intercept(chain: chain)
            }
        }
    }
    
    func failureInterceptors<T>(router: Router,
                                request: DataRequest,
                                error: Error) -> [(@escaping InterceptorCompletion<T>) -> ()] {
        return failureInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(leash: self, router: router, request: request, completion: completion)
                interceptor.intercept(chain: chain, error: error)
            }
        }
    }
    
    func successInterceptors<T>(router: Router,
                                request: DataRequest,
                                response: DefaultDataResponse) -> [(@escaping InterceptorCompletion<T>) -> ()] {
        return successInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(leash: self, router: router, request: request, completion: completion)
                interceptor.intercept(chain: chain, response: response)
            }
        }
    }
    
    func completionInterceptors<T>(router: Router,
                                   request: DataRequest,
                                   response: Response<T>) -> [(@escaping InterceptorCompletion<T>) -> ()] {
        return completionInterceptors.map { interceptor in
            return { completion in
                let chain = InterceptorChain(leash: self, router: router, request: request, completion: completion)
                interceptor.intercept(chain: chain, response: response)
            }
        }
    }
    
}
