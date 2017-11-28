//
//  ResponseTests.swift
//  Example
//
//  Created by Luciano Polit on 11/28/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import XCTest
@testable import Leash

class ResponseTests: BaseTestCase {
    
    let failure = Response<Data>.failure(Leash.Error.unknown)
    let success = Response.success(value: Data(), extra: "extra")
    
}

// MARK: - Utils

extension ResponseTests {
    
    func testFailure() {
        XCTAssertTrue(failure.isFailure)
        XCTAssertFalse(success.isFailure)
    }
    
    func testIsSuccess() {
        XCTAssertFalse(failure.isSuccess)
        XCTAssertTrue(success.isSuccess)
    }
    
    func testError() {
        XCTAssertNotNil(failure.error)
        XCTAssertNil(success.error)
    }
    
    func testValue() {
        XCTAssertNil(failure.value)
        XCTAssertNotNil(success.value)
    }
    
    func testExtra() {
        XCTAssertNil(failure.extra)
        XCTAssertNotNil(success.extra)
    }
    
}
