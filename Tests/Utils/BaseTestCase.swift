//
//  BaseTestCase.swift
//  Example
//
//  Created by Luciano Polit on 11/14/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import XCTest
@testable import Leash

class BaseTestCase: XCTestCase {
    
    static let scheme = "http"
    static let host = "localhost"
    static let port = 8080
    static let path = "api"
    
    var builder: Manager.Builder {
        return Manager.Builder()
            .scheme(ClientTests.scheme)
            .host(ClientTests.host)
            .port(ClientTests.port)
            .path(ClientTests.path)
    }
    var manager: Manager! {
        didSet {
            client = Client(manager: manager)
        }
    }
    var client: Client!
    
    override func setUp() {
        manager = builder.build()
    }
    
}

extension BaseTestCase {
    
    @discardableResult
    func assertErrorThrown(_ closure: () throws -> ()) -> Swift.Error {
        enum AssertError: Swift.Error {
            case assertFailed
        }
        
        do {
            try closure()
            XCTFail()
            return AssertError.assertFailed
        } catch {
            return error
        }
    }
    
    func assertNoErrorThrown(_ closure: () throws -> ()) {
        do {
            try closure()
        } catch {
            XCTFail()
        }
    }
    
}
