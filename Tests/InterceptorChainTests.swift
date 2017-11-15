//
//  InterceptorChainTests.swift
//  Example
//
//  Created by Luciano Polit on 11/14/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Alamofire
import XCTest
@testable import Leash

class InterceptorChainTests: BaseTestCase {
    
    typealias T = Data
    
    var count = 0
    var result: (response: Response<T>, finish: Bool)?
    var chain: InterceptorChain<T>!
    
    override func setUp() {
        super.setUp()
        assertNoErrorThrown {
            let endpoint = Endpoint()
            let dataRequest = try client.request(for: endpoint)
            chain = InterceptorChain(manager: manager, endpoint: endpoint, request: dataRequest) { result in
                self.count += 1
                self.result = result
            }
        }
    }
    
}

// MARK: - Completion

extension InterceptorChainTests {
    
    func testProceedCallsCompletionOnlyOneTime() {
        XCTAssertEqual(count, 0)
        chain.proceed()
        chain.proceed()
        chain.proceed()
        XCTAssertEqual(count, 1)
    }
    
    func testCompleteWithResponseCallsCompletionOnylOneTime() {
        XCTAssertEqual(count, 0)
        chain.complete(with: Response.success(value: Data(), extra: nil))
        chain.complete(with: Response.success(value: Data(), extra: nil))
        chain.complete(with: Response.success(value: Data(), extra: nil))
        XCTAssertEqual(count, 1)
    }
    
    func testCompleteWithSuccessCallsCompletionOnylOneTime() {
        XCTAssertEqual(count, 0)
        chain.complete(with: Data(), extra: nil)
        chain.complete(with: Data(), extra: nil)
        chain.complete(with: Data(), extra: nil)
        XCTAssertEqual(count, 1)
    }
    
    func testCompleteWithFailureCallsCompletionOnylOneTime() {
        XCTAssertEqual(count, 0)
        chain.complete(with: Leash.Error.dataUnavailable)
        chain.complete(with: Leash.Error.dataUnavailable)
        chain.complete(with: Leash.Error.dataUnavailable)
        XCTAssertEqual(count, 1)
    }
    
}

// MARK: - Result

extension InterceptorChainTests {
    
    func testProceedFinish() {
        chain.proceed()
        XCTAssertNil(result)
    }
    
    func testCompleteWithResponseFinishDefault() {
        chain.complete(with: Response.success(value: Data(), extra: nil))
        XCTAssertTrue(result?.finish ?? false)
    }
    
    func testCompleteWithResponseFinishTrue() {
        chain.complete(with: Response.success(value: Data(), extra: nil), finish: true)
        XCTAssertTrue(result?.finish ?? false)
    }
    
    func testCompleteWithResponseFinishFalse() {
        chain.complete(with: Response.success(value: Data(), extra: nil), finish: false)
        XCTAssertFalse(result?.finish ?? true)
    }
    
    func testCompleteWithSuccessFinishDefault() {
        chain.complete(with: Data(), extra: nil)
        XCTAssertTrue(result?.finish ?? false)
    }
    
    func testCompleteWithSuccessFinishTrue() {
        chain.complete(with: Data(), extra: nil, finish: true)
        XCTAssertTrue(result?.finish ?? false)
    }
    
    func testCompleteWithSuccessFinishFalse() {
        chain.complete(with: Data(), extra: nil, finish: false)
        XCTAssertFalse(result?.finish ?? true)
    }
    
    func testCompleteWithFailureFinishDefault() {
        chain.complete(with: Leash.Error.dataUnavailable)
        XCTAssertTrue(result?.finish ?? false)
    }
    
    func testCompleteWithFailureFinishTrue() {
        chain.complete(with: Leash.Error.dataUnavailable, finish: true)
        XCTAssertTrue(result?.finish ?? false)
    }
    
    func testCompleteWithFailureFinishFalse() {
        chain.complete(with: Leash.Error.dataUnavailable, finish: false)
        XCTAssertFalse(result?.finish ?? true)
    }
    
}
