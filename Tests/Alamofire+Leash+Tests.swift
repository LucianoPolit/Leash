//
//  Alamofire+Leash+Tests.swift
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

class AlamofireLeashTests: BaseTestCase {
    
    typealias T = PrimitiveEntity
    
    let successEndpoint = Endpoint(path: "this/is/a/path")
    let failureEndpoint = Endpoint(path: "this/is/a/different/path")
    
    override func setUp() {
        super.setUp()
        stub(condition: isEndpoint(successEndpoint)) { _ in
            let entity = PrimitiveEntity(first: "some", second: 10, third: true).toJSON()
            return OHHTTPStubsResponse(jsonObject: entity, statusCode: 200, headers: nil)
        }
        stub(condition: isEndpoint(failureEndpoint)) { _ in
            return OHHTTPStubsResponse(error: Leash.Error.dataUnavailable)
        }
    }
    
}

// MARK: - Interceptors

extension AlamofireLeashTests {
    
    func testCallsExecutionInterceptors() {
        let expectation = self.expectation(description: "Expected to call all the interceptors")
        let interceptors = Array(repeating: MockExecutionInterceptor<T>(), count: 3)
        var builder = self.builder
        interceptors.forEach {
            builder = builder.add(interceptor: $0)
        }
        testCallsInterceptors(interceptors: interceptors) {
            expectation.fulfill()
        }
        executeRequest(builder: builder, endpoint: successEndpoint)
        waitForExpectations(timeout: 5)
    }
    
    func testCallsFailureInterceptorsWhenFailure() {
        let expectation = self.expectation(description: "Expected to call all the interceptors")
        let interceptors = Array(repeating: MockFailureInterceptor<T>(), count: 3)
        var builder = self.builder
        interceptors.forEach {
            builder = builder.add(interceptor: $0)
        }
        testCallsInterceptors(interceptors: interceptors) {
            expectation.fulfill()
        }
        executeRequest(builder: builder, endpoint: failureEndpoint)
        waitForExpectations(timeout: 5)
    }
    
    func testNotCallsFailureInterceptorsWhenSuccess() {
        let expectation = self.expectation(description: "Expected to not call any interceptor")
        let interceptors = Array(repeating: MockFailureInterceptor<T>(), count: 3)
        var builder = self.builder
        interceptors.forEach {
            builder = builder.add(interceptor: $0)
        }
        testCallsInterceptors(interceptors: interceptors, completion: nil)
        executeRequest(builder: builder, endpoint: successEndpoint) { _ in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testNotCallsSuccessInterceptorsWhenFailure() {
        let expectation = self.expectation(description: "Expected to not call any interceptor")
        let interceptors = Array(repeating: MockSuccessInterceptor<T>(), count: 3)
        var builder = self.builder
        interceptors.forEach {
            builder = builder.add(interceptor: $0)
        }
        testCallsInterceptors(interceptors: interceptors, completion: nil)
        executeRequest(builder: builder, endpoint: failureEndpoint) { _ in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testCallsSuccessInterceptorsWhenSuccess() {
        let expectation = self.expectation(description: "Expected to call all the interceptors")
        let interceptors = Array(repeating: MockSuccessInterceptor<T>(), count: 3)
        var builder = self.builder
        interceptors.forEach {
            builder = builder.add(interceptor: $0)
        }
        testCallsInterceptors(interceptors: interceptors) {
            expectation.fulfill()
        }
        executeRequest(builder: builder, endpoint: successEndpoint)
        waitForExpectations(timeout: 5)
    }
    
    func testCallsCompletionInterceptorsWhenFailure() {
        let expectation = self.expectation(description: "Expected to call all the interceptors")
        let interceptors = Array(repeating: MockCompletionInterceptor<T>(), count: 3)
        var builder = self.builder
        interceptors.forEach {
            builder = builder.add(interceptor: $0)
        }
        testCallsInterceptors(interceptors: interceptors) {
            expectation.fulfill()
        }
        executeRequest(builder: builder, endpoint: failureEndpoint)
        waitForExpectations(timeout: 5)
    }
    
    func testCallsCompletionInterceptorsWhenSuccess() {
        let expectation = self.expectation(description: "Expected to call all the interceptors")
        let interceptors = Array(repeating: MockCompletionInterceptor<T>(), count: 3)
        var builder = self.builder
        interceptors.forEach {
            builder = builder.add(interceptor: $0)
        }
        testCallsInterceptors(interceptors: interceptors) {
            expectation.fulfill()
        }
        executeRequest(builder: builder, endpoint: successEndpoint)
        waitForExpectations(timeout: 5)
    }
    
}

// MARK: - Response

extension AlamofireLeashTests {
    
    
    
}

// MARK: - Errors

extension AlamofireLeashTests {
    
    func testDecodingError() {
        let expectation = self.expectation(description: "Expected to return a decoding error")
        let endpoint = Endpoint(path: "decoding/error")
        stub(condition: isEndpoint(endpoint)) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        executeRequest(builder: builder, endpoint: endpoint) { response in
            guard case .failure(let error) = response, case Leash.Error.decoding = error else {
                XCTFail()
                return
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
}

// MARK: - Utils

private extension AlamofireLeashTests {
    
    func testCallsInterceptors<T: MockInterceptor>(interceptors: [T], completion: (() -> ())?) {
        var calls = 0
        interceptors.forEach {
            $0.completion = {
                $0?.proceed()
                calls += 1
                if calls == interceptors.count {
                    completion?()
                }
            }
        }
    }
    
    func executeRequest(builder: Manager.Builder,
                        endpoint: Endpoint,
                        completion: ((Response<PrimitiveEntity>) -> ())? = nil) {
        manager = builder.build()
        assertNoErrorThrown {
            let dataRequest = try client.request(for: endpoint)
            dataRequest.response(manager, successEndpoint) { response in
                completion?(response)
            }
        }
    }
    
}

private protocol MockInterceptor: class {
    associatedtype T
    var completion: ((InterceptorChain<T>?) -> ())? { get set }
    var interceptCalled: Bool { get }
    var interceptParameterChain: InterceptorChain<T>? { get }
}

extension MockExecutionInterceptor: MockInterceptor { }
extension MockFailureInterceptor: MockInterceptor { }
extension MockSuccessInterceptor: MockInterceptor { }
extension MockCompletionInterceptor: MockInterceptor { }
