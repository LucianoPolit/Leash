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
    public func response<T: Decodable>(_ completion: @escaping (Response<T>) -> Void) -> Self {
        return response { response in
            
        }
    }
    
}

extension DataResponse {
    
    public func decodedResponse<T: Decodable>() -> Response<T> {
        guard let data = data else {
            return .failure(error: .dataUnavailable)
        }
        
        do {
            let value = try JSONDecoder().decode(T.self, from: data)
            return .success(value: value, extra: nil)
        } catch {
            return .failure(error: .decoding(error))
        }
    }
    
}
