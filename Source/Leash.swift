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
    
    public let sessionManager: SessionManager
    public let executionInterceptors: [ExecutionInterceptor]
    public let failureInterceptors: [FailureInterceptor]
    public let successInterceptors: [SuccessInterceptor]
    public let completionInterceptors: [CompletionInterceptor]
    
    init?(builder: Builder) {
        guard let builderScheme = builder.scheme, let builderHost = builder.host else { return nil }
        
        scheme = builderScheme
        host = builderHost
        port = builder.port
        path = builder.path
        authenticator = builder.authenticator
        
        sessionManager = builder.sessionManager
        executionInterceptors = builder.executionInterceptors
        failureInterceptors = builder.failureInterceptors
        successInterceptors = builder.successInterceptors
        completionInterceptors = builder.completionInterceptors
    }
    
    public class Builder {
        
        var scheme: String?
        var host: String?
        var port: Int?
        var path: String?
        var authenticator: Authenticator?
        
        var sessionManager = SessionManager.default
        var executionInterceptors: [ExecutionInterceptor] = []
        var failureInterceptors: [FailureInterceptor] = []
        var successInterceptors: [SuccessInterceptor] = []
        var completionInterceptors: [CompletionInterceptor] = []
        
        func scheme(_ scheme: String) -> Builder {
            self.scheme = scheme
            return self
        }
        
        func host(_ host: String) -> Builder {
            self.host = host
            return self
        }
        
        func port(_ port: Int) -> Builder {
            self.port = port
            return self
        }
        
        func path(_ path: String) -> Builder {
            self.path = path
            return self
        }
        
        func authenticator(_ authenticator: Authenticator) -> Builder {
            self.authenticator = authenticator
            return self
        }
        
        func sessionManager(_ sessionManager: SessionManager) -> Builder {
            self.sessionManager = sessionManager
            return self
        }
        
        func add(interceptor: ExecutionInterceptor) {
            executionInterceptors.append(interceptor)
        }
        
        func add(interceptor: FailureInterceptor) {
            failureInterceptors.append(interceptor)
        }
        
        func add(interceptor: SuccessInterceptor) {
            successInterceptors.append(interceptor)
        }
        
        func add(interceptor: CompletionInterceptor) {
            completionInterceptors.append(interceptor)
        }
        
        func build() -> Leash? {
            return Leash(builder: self)
        }
        
    }
    
}
