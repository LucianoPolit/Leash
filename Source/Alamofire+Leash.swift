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
