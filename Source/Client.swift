//
//  Client.swift
//  Pods-Example
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation
import Alamofire

class Client {
    
    // MARK: - Properties
    
    let leash: Leash
    
    // MARK: - Initializers
    
    init(leash: Leash) {
        self.leash = leash
    }
    
    // MARK: - Methods
    
    @discardableResult
    public func execute<T: Decodable>(router: Router, completion: @escaping (Response<T>) -> Void) -> DataRequest? {
        do {
            return try self.request(for: router).response(leash, completion)
        } catch let error as Error {
            completion(.failure(error: error))
        } catch {
            completion(.failure(error: .encoding(error)))
        }
        
        return nil
    }
    
    public func request(for router: Router) throws -> DataRequest {
        return leash.sessionManager.request(try urlRequest(for: router))
    }
    
    public func urlRequest(for router: Router) throws -> URLRequest {
        guard let url = URL(string: leash.baseURL) else {
            throw Error.invalidURL
        }
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(router.path))
        urlRequest.httpMethod = router.method.rawValue
        try urlRequest.encode(router: router, with: leash.jsonEncoder)
        urlRequest.addAuthenticator(leash.authenticator)

        return urlRequest
    }
    
}

// MARK: - Utils

private extension Leash {
    
    var baseURL: String {
        var baseURL = scheme + host
        
        if let port = port {
            baseURL += ":\(port)"
        }
        
        if let path = path {
            baseURL += "/\(path)"
        }
        
        return baseURL
    }
    
}

private extension URLRequest {
    
    mutating func addValueIfPossible(value: String?, forHTTPHeaderField field: String?) {
        guard let value = value, let field = field else { return }
        addValue(value, forHTTPHeaderField: field)
    }
    
    mutating func addAuthenticator(_ authenticator: Authenticator?) {
        addValueIfPossible(value: authenticator?.authentication,
                           forHTTPHeaderField: authenticator?.header)
    }
    
}

private extension URLRequest {
    
    mutating func encode(router: Router, with jsonEncoder: JSONEncoder) throws {
        guard let parameters = router.parameters else { return }
        
        if router.method.isBodyEncodable,
            let encodable = parameters as? Encodable {
            httpBody = try encodable.encoded(with: jsonEncoder)
        }
        
        if router.method.isQueryEncodable,
            let querySerializable = parameters as? QuerySerializable {
            try encode(query: querySerializable.toQuery())
        }
    }
    
    mutating func encode(query: [String : CustomStringConvertible]) throws {
        self = try URLEncoding().encode(self, with: query)
    }
    
}

private extension Encodable {
    
    func encoded(with jsonEncoder: JSONEncoder) throws -> Data {
        return try jsonEncoder.encode(self)
    }
    
}

private extension HTTPMethod {
    
    var isBodyEncodable: Bool {
        return !isQueryEncodable
    }
    
    var isQueryEncodable: Bool {
        return self == .get
    }
    
}

private extension Authenticator {
    
    var header: String {
        return Self.header
    }
    
}
