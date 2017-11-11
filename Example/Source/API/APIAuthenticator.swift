//
//  APIAuthenticator.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash

class APIAuthenticator {
    
    // MARK: - Properties
    
    private(set) var userID: String?
    
    // MARK: - Initializers
    
    init(id: String?) {
        userID = id
    }
    
    // MARK: - Methods
    
    func signIn(_ id: String) {
        userID = id
    }
    
    func signOut() {
        userID = nil
    }
    
}

extension APIAuthenticator: Authenticator {
    
    static var header: String = "Authentication"
    
    var authentication: String? {
        return userID
    }
    
}
