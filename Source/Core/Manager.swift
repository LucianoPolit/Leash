//
//  Manager.swift
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

/// Contains all the information needed to properly reach an API.
public class Manager {
    
    /// URL of the API.
    public let url: URL
    /// Authenticator of the API.
    public let authenticator: Authenticator?
    
    /// Interceptors called before a request is executed.
    public let executionInterceptors: [ExecutionInterceptor]
    /// Interceptors called when there is a problem executing a request.
    public let failureInterceptors: [FailureInterceptor]
    /// Interceptors called when there is no problem executing a request.
    public let successInterceptors: [SuccessInterceptor]
    /// Interceptors called before the completion handler.
    public let completionInterceptors: [CompletionInterceptor]
    /// Interceptors called after a serialization operation.
    public let serializationInterceptors: [SerializationInterceptor]
    
    /// Responsible for executing the requests and calling the interceptors when needed.
    public let sessionManager: SessionManager
    /// Encoder of the body of the requests.
    public let jsonEncoder: JSONEncoder
    /// Decoder of the body of the responses.
    public let jsonDecoder: JSONDecoder
    
    /// Initializes and returns a newly allocated object with the specified builder.
    public init(builder: Builder) {
        guard let builderURL = builder.url ?? URL(builder: builder) else { fatalError("Leash -> Manager -> Invalid URL") }
        
        url = builderURL
        authenticator = builder.authenticator
        
        executionInterceptors = builder.executionInterceptors
        failureInterceptors = builder.failureInterceptors
        successInterceptors = builder.successInterceptors
        completionInterceptors = builder.completionInterceptors
        serializationInterceptors = builder.serializationInterceptors
        
        sessionManager = builder.sessionManager
        sessionManager.startRequestsImmediately = false
        
        jsonEncoder = builder.jsonEncoder
        jsonDecoder = builder.jsonDecoder
    }
    
    /// Builder of Managers.
    public class Builder {
        
        var url: URL?
        var scheme: String?
        var host: String?
        var port: Int?
        var path: String?
        var authenticator: Authenticator?
        
        var executionInterceptors: [ExecutionInterceptor] = []
        var failureInterceptors: [FailureInterceptor] = []
        var successInterceptors: [SuccessInterceptor] = []
        var completionInterceptors: [CompletionInterceptor] = []
        var serializationInterceptors: [SerializationInterceptor] = []
        
        var sessionManager = SessionManager.default
        var jsonEncoder = JSONEncoder()
        var jsonDecoder = JSONDecoder()
        
        /// Initializes and returns a newly allocated object.
        public init() { }
        
        /// Sets the URL of the API.
        public func url(_ url: URL) -> Self {
            self.url = url
            return self
        }
        
        /// Sets the URL of the API.
        public func url(_ url: String) -> Self {
            self.url = URL(string: url)
            return self
        }
        
        /// Sets the scheme of the API.
        public func scheme(_ scheme: String) -> Self {
            self.scheme = scheme
            return self
        }
        
        /// Sets the host of the API.
        public func host(_ host: String) -> Self {
            self.host = host
            return self
        }
        
        /// Sets the port of the API.
        public func port(_ port: Int) -> Self {
            self.port = port
            return self
        }
        
        /// Sets the path of the API.
        public func path(_ path: String) -> Self {
            self.path = path
            return self
        }
        
        /// Sets the authenticator of the API.
        public func authenticator(_ authenticator: Authenticator) -> Self {
            self.authenticator = authenticator
            return self
        }
        
        /// Adds an interceptor.
        public func add(interceptor: Interceptor) -> Self {
            executionInterceptors.appendIfPossible(interceptor)
            failureInterceptors.appendIfPossible(interceptor)
            successInterceptors.appendIfPossible(interceptor)
            completionInterceptors.appendIfPossible(interceptor)
            serializationInterceptors.appendIfPossible(interceptor)
            return self
        }
        
        /// Sets the session manager.
        public func sessionManager(_ sessionManager: SessionManager) -> Self {
            self.sessionManager = sessionManager
            return self
        }
        
        /// Sets the JSON encoder.
        public func jsonEncoder(_ configuration: (JSONEncoder) -> ()) -> Self {
            configuration(jsonEncoder)
            return self
        }
        
        /// Sets the JSON decoder.
        public func jsonDecoder(_ configuration: (JSONDecoder) -> ()) -> Self {
            configuration(jsonDecoder)
            return self
        }
        
        /// Sets the date formatter of the encoder and the decoder.
        public func jsonDateFormatter(_ dateFormatter: DateFormatter) -> Self {
            jsonEncoder.dateEncodingStrategy = .formatted(dateFormatter)
            jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
            return self
        }
        
        /// Builds the manager.
        public func build() -> Manager {
            return Manager(builder: self)
        }
        
    }
    
}

// MARK: - Utils

private extension URL {
    
    init?(builder: Manager.Builder) {
        guard let scheme = builder.scheme, let host = builder.host else { return nil }
        
        var baseURL = scheme + "://" + host
        
        if let port = builder.port {
            baseURL += ":\(port)"
        }
        
        if let path = builder.path {
            baseURL += "/\(path)"
        }
        
        self.init(string: baseURL)
    }
    
}

private extension Array {
    
    mutating func appendIfPossible(_ newElement: Any) {
        guard let newElement = newElement as? Element else { return }
        append(newElement)
    }
    
}
