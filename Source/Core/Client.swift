//
//  Client.swift
//
//  Copyright (c) 2017-2018 Luciano Polit <lucianopolit@gmail.com>
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
import Alamofire

/// Responsible for creating and executing requests.
open class Client {
    
    // MARK: - Properties
    
    /// The manager that is used to create and execute requests.
    public let manager: Manager
    
    // MARK: - Initializers
    
    /// Initializes and returns a newly allocated object with the specified parameters.
    public init(manager: Manager) {
        self.manager = manager
    }
    
    // MARK: - Methods
    
    /// Creates and executes the request for the specified endpoint.
    ///
    /// - Parameter endpoint: Contains all the information needed to create the request.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    /// - Parameter completion: Handler of the response.
    ///
    /// - Returns: The created request.
    @discardableResult
    open func execute<T: Decodable>(_ endpoint: Endpoint,
                                    queue: DispatchQueue? = nil,
                                    completion: @escaping (Response<T>) -> ()) -> DataRequest? {
        do {
            let request = try self.request(for: endpoint)
            return request.responseDecodable(queue: queue,
                                             client: self,
                                             endpoint: endpoint,
                                             completion: completion)
        } catch {
            completion(.failure(Error.encoding(error)))
            return nil
        }
    }
    
    /// Creates the request for the specified endpoint.
    ///
    /// - Parameter endpoint: Contains all the information needed to create the request.
    ///
    /// - Returns: The created request.
    open func request(for endpoint: Endpoint) throws -> DataRequest {
        let urlRequest = try self.urlRequest(for: endpoint)
        return manager.sessionManager.request(urlRequest)
    }
    
    /// Creates the URL request for the specified endpoint.
    ///
    /// Some of the data is used from the manager and some other from the endpoint.
    /// Regarding the endpoint parameters, they are encoded on the body/query depending on the method.
    ///
    /// There are different acceptable types depending on the encoding:
    ///
    /// - For the body, Encodable or [String : Any].
    /// - For the query, QueryEncodable or [String : CustomStringConvertible].
    ///
    /// In case that another type is required, this method must be overridden.
    ///
    /// - Parameter endpoint: Contains all the information needed to create the URL request.
    ///
    /// - Returns: The created URL request.
    open func urlRequest(for endpoint: Endpoint) throws -> URLRequest {
        var urlRequest = URLRequest(url: manager.url.appendingPathComponent(endpoint.path))
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.addAuthenticator(manager.authenticator)
        try urlRequest.encode(endpoint: endpoint, with: manager.jsonEncoder)
        return urlRequest
    }
    
}

// MARK: - Utils

private extension URLRequest {
    
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
        
        if endpoint.method.isBodyEncodable, let json = parameters as? [String: Any] {
            return try encode(json: json)
        }
        
        if endpoint.method.isBodyEncodable, let encodable = parameters as? Encodable {
            return try encode(encodable: encodable, with: jsonEncoder)
        }
        
        if endpoint.method.isQueryEncodable, let query = parameters as? [String: CustomStringConvertible] {
            return try encode(query: query)
        }
        
        if endpoint.method.isQueryEncodable, let queryEncodable = parameters as? QueryEncodable {
            return try encode(query: queryEncodable.toQuery())
        }
    }
    
    mutating func encode(json: [String: Any]) throws {
        self = try JSONEncoding().encode(self, with: json)
    }
    
    mutating func encode(encodable: Encodable, with jsonEncoder: JSONEncoder) throws {
        setValue("application/json", forHTTPHeaderField: "Content-Type")
        httpBody = try encodable.encoded(with: jsonEncoder)
    }
    
    mutating func encode(query: [String: CustomStringConvertible]) throws {
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
