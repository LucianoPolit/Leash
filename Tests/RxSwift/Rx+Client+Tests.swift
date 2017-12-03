//
//  Rx+Client+Tests.swift
//  Example
//
//  Created by Luciano Polit on 12/3/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import RxSwift
import XCTest
import OHHTTPStubs
@testable import Leash

// MARK: - DataRequest

extension ClientTests {
    
    func testRxRequestCallsSessionManager() {
        let endpoint = Endpoint()
        let sessionManager = MockSessionManager()
        manager = builder
            .sessionManager(sessionManager)
            .build()
        assertNoErrorThrown {
            let dataRequest = try client.request(for: endpoint)
            XCTAssertTrue(sessionManager.requestCalled)
            XCTAssertTrue(dataRequest.request?.url?.absoluteString.contains(baseURL) ?? false)
        }
    }
    
    func testRxExecuteCallsResponse() {
        let expectation = self.expectation(description: "Expected to find a success response")
        let disposeBag = DisposeBag()
        let endpoint = Endpoint(path: "response/123")
        let json = ["some" : "123"]
        stub(condition: isEndpoint(endpoint)) { _ in
            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }
        let single: Single<[String : String]> = client.rx.execute(endpoint)
        single
            .subscribe(onSuccess: { value in
                XCTAssertEqual(value, json)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        waitForExpectations(timeout: 5)
    }
    
}

// MARK: - Errors

extension ClientTests {
    
    func testRxEncodingError() {
        let expectation = self.expectation(description: "Expected to find a failure response")
        let disposeBag = DisposeBag()
        let endpoint = Endpoint(method: .post, parameters: Data())
        let single: Single<ReactiveResponse<Data>> = client.rx.execute(endpoint)
        single
            .subscribe(onError: { error in
                guard case Leash.Error.encoding = error else {
                    XCTFail()
                    return
                }
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        waitForExpectations(timeout: 5)
    }
    
}
