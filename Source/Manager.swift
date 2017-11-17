//
//  Manager.swift
//
//  Copyright (c) 2017 Luciano Polit <lucianopolit@gmail.com>
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

/// Contains all the information needed to properly reach an API.
public class Manager {
    
    /// Scheme of the API.
    public let scheme: String?
    /// Host of the API.
    public let host: String?
    /// Port of the API.
    public let port: Int?
    /// Path of the API.
    public let path: String?
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
    
    /// Responsible for executing the requests and calling the interceptors when needed.
    public let sessionManager: SessionManager
    /// Encoder of the body of the requests.
    public let jsonEncoder: JSONEncoder
    /// Decoder of the body of the responses.
    public let jsonDecoder: JSONDecoder
    
    /// Initializes and returns a newly allocated object with the specified builder.
    public init(builder: Builder) {
        scheme = builder.scheme
        host = builder.host
        port = builder.port
        path = builder.path
        authenticator = builder.authenticator
        
        executionInterceptors = builder.executionInterceptors
        failureInterceptors = builder.failureInterceptors
        successInterceptors = builder.successInterceptors
        completionInterceptors = builder.completionInterceptors
        
        sessionManager = builder.sessionManager
        jsonEncoder = builder.jsonEncoder
        jsonDecoder = builder.jsonDecoder
    }
    
    /// Builder of Managers.
    public class Builder {
        
        var scheme: String?
        var host: String?
        var port: Int?
        var path: String?
        var authenticator: Authenticator?
        
        var executionInterceptors: [ExecutionInterceptor] = []
        var failureInterceptors: [FailureInterceptor] = []
        var successInterceptors: [SuccessInterceptor] = []
        var completionInterceptors: [CompletionInterceptor] = []
        
        var sessionManager = SessionManager.default
        var jsonEncoder = JSONEncoder()
        var jsonDecoder = JSONDecoder()
        
        /// Initializes and returns a newly allocated object.
        public init() { }
        
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
        
        /// Adds an execution interceptor.
        public func add(interceptor: ExecutionInterceptor) -> Self {
            executionInterceptors.append(interceptor)
            return self
        }
        
        /// Adds a failure interceptor.
        public func add(interceptor: FailureInterceptor) -> Self {
            failureInterceptors.append(interceptor)
            return self
        }
        
        /// Adds a success interceptor.
        public func add(interceptor: SuccessInterceptor) -> Self {
            successInterceptors.append(interceptor)
            return self
        }
        
        /// Adds a completion interceptor.
        public func add(interceptor: CompletionInterceptor) -> Self {
            completionInterceptors.append(interceptor)
            return self
        }
        
        /// Sets the session manager.
        public func sessionManager(_ sessionManager: SessionManager) -> Self {
            self.sessionManager = sessionManager
            self.sessionManager.startRequestsImmediately = false
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
