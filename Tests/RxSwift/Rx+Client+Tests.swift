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
#if !COCOAPODS
import OHHTTPStubsSwift
@testable import RxLeash
#endif

// MARK: - DataRequest

extension ClientTests {
    
    func testRxRequestCallsSessionManager() {
        let endpoint = Endpoint()
        let session = MockSession()
        manager = builder
            .session(session)
            .build()
        assertNoErrorThrown {
            let _ = try client.request(for: endpoint)
            XCTAssertTrue(session.requestCalled)
        }
    }
    
    func testRxExecuteCallsResponse() {
        let expectation = self.expectation(description: "Expected to find a success response")
        let disposeBag = DisposeBag()
        let endpoint = Endpoint(path: "response/123")
        let json = ["some": "123"]
        stub(condition: isEndpoint(endpoint)) { _ in
            return HTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }
        let observable: Observable<[String: String]> = client.rx.execute(endpoint)
        observable
            .subscribe(onNext: { value in
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
        let observable: Observable<ReactiveResponse<Data>> = FailureClient(manager: manager).rx.execute(endpoint)
        observable
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
