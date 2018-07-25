//
//  CacheInterceptor.swift
//  Example
//
//  Created by Luciano Polit on 25/07/2018.
//  Copyright © 2018 Luciano Polit. All rights reserved.
//

import Foundation
import Leash

/// Interceptor responsible for caching the responses and inject them when needed.
class CacheInterceptor: Leash.CacheInterceptor {
    
    init() {
        super.init(dataStore: DataPersistor())
        register(policy: CachePolicy.CacheAndRenew(), to: "/expenses/[0-9]*/")
        register(policy: CachePolicy.CacheOnlyOnError(), to: "/expenses/")
    }
    
}

private class DataPersistor: DataStore {
    
    func data(for endpoint: Leash.Endpoint) -> Data? {
        return nil
    }
    
    func save(_ data: Data, for endpoint: Leash.Endpoint) { }
    
}
