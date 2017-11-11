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
    
    public let leash: Leash
    
    // MARK: - Initializers
    
    public init(leash: Leash) {
        self.leash = leash
    }
    
    // MARK: - Methods
    
    @discardableResult
    open func execute<T: Decodable>(endpoint: Endpoint, completion: @escaping (Response<T>) -> Void) -> DataRequest? {
        do {
            let request = try self.request(for: endpoint)
            request.response(leash, endpoint, completion)
            return request
        } catch let error as Error {
            completion(.failure(error))
        } catch {
            completion(.failure(Error.encoding(error)))
        }
        
        return nil
    }
    
    open func request(for endpoint: Endpoint) throws -> DataRequest {
        return leash.sessionManager.request(try urlRequest(for: endpoint))
    }
    
    open func urlRequest(for endpoint: Endpoint) throws -> URLRequest {
        guard let url = URL(string: leash.baseURL) else { throw Error.invalidURL }
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(endpoint.path))
        urlRequest.httpMethod = endpoint.method.rawValue
        try urlRequest.encode(endpoint: endpoint, with: leash.jsonEncoder)
        urlRequest.addAuthenticator(leash.authenticator)

        return urlRequest
    }
    
}

// MARK: - Utils

private extension Leash {
    
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
        
        if endpoint.method.isBodyEncodable, let encodable = parameters as? Encodable {
            setDefaultValue(value: "application/json", forHTTPHeaderField: "Content-Type")
            httpBody = try encodable.encoded(with: jsonEncoder)
        }
        
        if endpoint.method.isBodyEncodable, let json = parameters as? [String : Any] {
            try encode(json: json)
        }
        
        if endpoint.method.isQueryEncodable, let querySerializable = parameters as? QuerySerializable {
            try encode(query: querySerializable.toQuery())
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
