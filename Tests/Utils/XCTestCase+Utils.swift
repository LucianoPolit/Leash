//
//  XCTestCase+Utils.swift
//  Example
//
//  Created by Luciano Polit on 11/14/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
    
    private enum AssertError: Swift.Error {
        case assertFailed
    }
    
    @discardableResult
    func assertErrorThrown(_ closure: () throws -> ()) -> Swift.Error {
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
