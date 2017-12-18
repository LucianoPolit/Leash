//
//  API.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash

/// Responsible for configuring all the requirements to reach the API.
class API {
    
    // MARK: - Domain
    
    static let scheme = "http"
    static let host = "localhost"
    static let port = 8080
    static let path = "api"
    
    // MARK: - Properties
    
    let manager: Manager
    let authenticator: APIAuthenticator
    
    // MARK: - Clients
    
    var expenses: ExpensesClient
    
    // MARK: - Initializers
    
    init(authenticator: APIAuthenticator) {
        self.authenticator = authenticator
        let logger = LoggerInterceptor()
        manager = Manager.Builder()
            .scheme(API.scheme)
            .host(API.host)
            .port(API.port)
            .path(API.path)
            .authenticator(authenticator)
            .jsonDateFormatter(APIDateFormatter)
            .add(interceptor: BodyValidator())
            .add(interceptor: ResponseValidator())
            .add(interceptor: logger as ExecutionInterceptor)
            .add(interceptor: logger as CompletionInterceptor)
            .add(interceptor: logger as SerializationInterceptor)
            .build()
        expenses = ExpensesClient(manager: manager)
    }
    
}
