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
import OHHTTPStubs
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
            chain = InterceptorChain(client: client, endpoint: endpoint, request: dataRequest) { result in
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
        chain.complete(with: Leash.Error.unknown)
        chain.complete(with: Leash.Error.unknown)
        chain.complete(with: Leash.Error.unknown)
        XCTAssertEqual(count, 1)
    }
    
}

// MARK: - Result

extension InterceptorChainTests {
    
    func testProceed() {
        chain.proceed()
        XCTAssertNil(result)
    }
    
    func testRetry() {
        let expectation = self.expectation(description: "Expected to call all the interceptors")
        let authenticator = Authenticator()
        let futureAuthentication = "ThisIsNew!"
        manager = builder
            .authenticator(authenticator)
            .build()
        chain = InterceptorChain(client: client, endpoint: chain.endpoint, request: chain.request) { result in
            guard let result = result,
                case .failure(let error) = result.response,
                case Leash.Error.unknown = error else { return XCTFail() }
            XCTAssertTrue(result.finish)
            expectation.fulfill()
        }
        stub(condition: isEndpoint(chain.endpoint)) { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: Authenticator.header), futureAuthentication)
            return OHHTTPStubsResponse(error: Leash.Error.unknown)
        }
        assertNoErrorThrown {
            authenticator.authentication = futureAuthentication
            try chain?.retry()
        }
        waitForExpectations(timeout: 5)
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
        chain.complete(with: Leash.Error.unknown)
        XCTAssertTrue(result?.finish ?? false)
    }
    
    func testCompleteWithFailureFinishTrue() {
        chain.complete(with: Leash.Error.unknown, finish: true)
        XCTAssertTrue(result?.finish ?? false)
    }
    
    func testCompleteWithFailureFinishFalse() {
        chain.complete(with: Leash.Error.unknown, finish: false)
        XCTAssertFalse(result?.finish ?? true)
    }
    
}
