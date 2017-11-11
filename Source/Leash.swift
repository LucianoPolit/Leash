//
//  Leash.swift
//  Pods-Example
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation
import Alamofire

public class Leash {
    
    public let scheme: String
    public let host: String
    public let port: Int?
    public let path: String?
    public let authenticator: Authenticator?
    
    public let executionInterceptors: [ExecutionInterceptor]
    public let failureInterceptors: [FailureInterceptor]
    public let successInterceptors: [SuccessInterceptor]
    public let completionInterceptors: [CompletionInterceptor]
    
    public let sessionManager: SessionManager
    public let jsonEncoder: JSONEncoder
    public let jsonDecoder: JSONDecoder
    
    public init?(builder: Builder) {
        guard let builderScheme = builder.scheme, let builderHost = builder.host else { return nil }
        
        scheme = builderScheme
        host = builderHost
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
        
        public init() { }
        
        public func scheme(_ scheme: String) -> Builder {
            self.scheme = scheme
            return self
        }
        
        public func host(_ host: String) -> Builder {
            self.host = host
            return self
        }
        
        public func port(_ port: Int) -> Builder {
            self.port = port
            return self
        }
        
        public func path(_ path: String) -> Builder {
            self.path = path
            return self
        }
        
        public func authenticator(_ authenticator: Authenticator) -> Builder {
            self.authenticator = authenticator
            return self
        }
        
        public func add(interceptor: ExecutionInterceptor) {
            executionInterceptors.append(interceptor)
        }
        
        public func add(interceptor: FailureInterceptor) {
            failureInterceptors.append(interceptor)
        }
        
        public func add(interceptor: SuccessInterceptor) {
            successInterceptors.append(interceptor)
        }
        
        public func add(interceptor: CompletionInterceptor) {
            completionInterceptors.append(interceptor)
        }
        
        public func sessionManager(_ sessionManager: SessionManager) -> Builder {
            self.sessionManager = sessionManager
            return self
        }
        
        public func jsonEncoder(_ configuration: (JSONEncoder) -> ()) -> Builder {
            configuration(jsonEncoder)
            return self
        }
        
        public func jsonDecoder(_ configuration: (JSONDecoder) -> ()) -> Builder {
            configuration(jsonDecoder)
            return self
        }
        
        public func jsonDateFormatter(_ dateFormatter: DateFormatter) -> Builder {
            jsonEncoder.dateEncodingStrategy = .formatted(dateFormatter)
            jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
            return self
        }
        
        public func build() -> Leash? {
            return Leash(builder: self)
        }
        
    }
    
}
