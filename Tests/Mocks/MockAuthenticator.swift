//
//  MockAuthenticator.swift
//  Example
//
//  Created by Luciano Polit on 11/14/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
@testable import Leash

class MockAuthenticator: Leash.Authenticator {
    
    static var mockHeader = "Authorization"
    static var header: String {
        return mockHeader
    }
    
    var mockAuthentication: String?
    var authentication: String? {
        return mockAuthentication
    }
    
}
