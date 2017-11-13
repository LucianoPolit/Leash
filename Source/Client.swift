//
//  Client.swift
//  Pods-Example
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation
import Alamofire

open class Client {
    
    // MARK: - Properties
    
    public let manager: Manager
    
    // MARK: - Initializers
    
    public init(manager: Manager) {
        self.manager = manager
    }
    
    // MARK: - Methods
    
    @discardableResult
    open func execute<T: Decodable>(endpoint: Endpoint, completion: @escaping (Response<T>) -> Void) -> DataRequest? {
        do {
            let request = try self.request(for: endpoint)
            return request.response(manager, endpoint, completion)
        } catch let error as Error {
            completion(.failure(error))
        } catch {
            completion(.failure(Error.encoding(error)))
        }
        
        return nil
    }
    
    open func request(for endpoint: Endpoint) throws -> DataRequest {
        return manager.sessionManager.request(try urlRequest(for: endpoint))
    }
    
    open func urlRequest(for endpoint: Endpoint) throws -> URLRequest {
        guard let url = URL(string: manager.baseURL) else { throw Error.invalidURL }
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(endpoint.path))
        urlRequest.httpMethod = endpoint.method.rawValue
        try urlRequest.encode(endpoint: endpoint, with: manager.jsonEncoder)
        urlRequest.addAuthenticator(manager.authenticator)

        return urlRequest
    }
    
}

// MARK: - Utils

private extension Manager {
    
    var baseURL: String {
        var baseURL = scheme + "://" + host
        
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
    
    mutating func setDefaultValue(value: String, forHTTPHeaderField field: String) {
        guard self.value(forHTTPHeaderField: field) == nil else { return }
        setValue(value, forHTTPHeaderField: field)
    }
    
    mutating func addValueIfPossible(value: String?, forHTTPHeaderField field: String?) {
        guard let value = value, let field = field else { return }
        addValue(value, forHTTPHeaderField: field)
    }
    
    mutating func addAuthenticator(_ authenticator: Authenticator?) {
        addValueIfPossible(value: authenticator?.authentication, forHTTPHeaderField: authenticator?.header)
    }
    
}

private extension URLRequest {
    
    mutating func encode(endpoint: Endpoint, with jsonEncoder: JSONEncoder) throws {
        guard let parameters = endpoint.parameters else { return }
        
        if endpoint.method.isBodyEncodable, let json = parameters as? [String : Any] {
            return try encode(json: json)
        }
        
        if endpoint.method.isBodyEncodable, let encodable = parameters as? Encodable {
            setDefaultValue(value: "application/json", forHTTPHeaderField: "Content-Type")
            httpBody = try encodable.encoded(with: jsonEncoder)
        }
        
        if endpoint.method.isQueryEncodable, let queryEncodable = parameters as? QueryEncodable {
            try encode(query: queryEncodable.toQuery())
        }
        
        if endpoint.method.isQueryEncodable, let query = parameters as? [String : CustomStringConvertible] {
            try encode(query: query)
        }
    }
    
    mutating func encode(json: [String : Any]) throws {
        self = try JSONEncoding().encode(self, with: json)
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
