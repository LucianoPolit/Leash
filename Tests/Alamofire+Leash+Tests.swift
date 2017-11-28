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
            return OHHTTPStubsResponse(error: Leash.Error.unknown)
        }
    }
    
}

// MARK: - Interceptors

extension AlamofireLeashTests {
    
    func testCallsExecutionInterceptors() {
        let expectation = self.expectation(description: "Expected to call all the interceptors")
        let interceptors = Array(repeating: MockExecutionInterceptor(), count: 3)
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
        let interceptors = Array(repeating: MockFailureInterceptor(), count: 3)
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
        let interceptors = Array(repeating: MockFailureInterceptor(), count: 3)
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
        let interceptors = Array(repeating: MockSuccessInterceptor(), count: 3)
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
        let interceptors = Array(repeating: MockSuccessInterceptor(), count: 3)
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
        let interceptors = Array(repeating: MockCompletionInterceptor(), count: 3)
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
        let interceptors = Array(repeating: MockCompletionInterceptor(), count: 3)
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
    
    func testCallsInterceptorsWhenRetry() {
        let expectation = self.expectation(description: "Expected to call all the interceptors")
        var first = true
        let executionInterceptor = MockExecutionInterceptor { chain in
            defer { chain?.proceed() }
            guard !first else { return }
            expectation.fulfill()
        }
        let completionInterceptor = MockCompletionInterceptor { chain in
            defer { chain?.proceed() }
            guard first else { return }
            first = false
            self.assertNoErrorThrown {
                try chain?.retry()
            }
        }
        let builder = self.builder
            .add(interceptor: executionInterceptor)
            .add(interceptor: completionInterceptor)
        executeRequest(builder: builder, endpoint: successEndpoint)
        waitForExpectations(timeout: 5)
    }
    
}

// MARK: - Response

extension AlamofireLeashTests {
    
    func testData() {
        let expectation = self.expectation(description: "Expected to find a success response")
        assertNoErrorThrown {
            let endpoint = successEndpoint
            let dataRequest = try client.request(for: endpoint)
            dataRequest.response(client: client, endpoint: endpoint) { response in
                guard case .success = response else {
                    XCTFail()
                    return
                }
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5)
    }
    
    func testSerializer() {
        let expectation = self.expectation(description: "Expected to find a success response")
        assertNoErrorThrown {
            let endpoint = successEndpoint
            let dataRequest = try client.request(for: endpoint)
            let serializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            dataRequest.response(client: client, endpoint: endpoint, serializer: serializer) { response in
                guard case .success = response else {
                    XCTFail()
                    return
                }
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5)
    }
    
    func testDecodable() {
        let expectation = self.expectation(description: "Expected to find a success response")
        executeRequest(builder: builder, endpoint: successEndpoint) { response in
            guard case .success = response else {
                XCTFail()
                return
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testCustomDateFormatter() {
        let expectation = self.expectation(description: "Expected to find a success response")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.S'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let entity = DatedEntity(date: Date(timeIntervalSince1970: 100))
        let datedEndpoint = Endpoint(path: "dated/entity")
        stub(condition: isEndpoint(datedEndpoint)) { _ in
            let encoded = try? self.manager.jsonEncoder.encode(entity)
            return OHHTTPStubsResponse(data: encoded ?? Data(), statusCode: 200, headers: nil)
        }
        manager = builder
            .jsonDateFormatter(formatter)
            .build()
        assertNoErrorThrown {
            let dataRequest = try client.request(for: datedEndpoint)
            dataRequest.responseDecodable(client: client, endpoint: datedEndpoint) { (response: Response<DatedEntity>) in
                guard case .success(let result) = response else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(result.value, entity)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5)
    }
    
    func testDifferentEncoder() {
        let expectation = self.expectation(description: "Expected to find a success response")
        let entity = DatedEntity(date: Date(timeIntervalSince1970: 100))
        let datedEndpoint = Endpoint(path: "dated/entity")
        stub(condition: isEndpoint(datedEndpoint)) { _ in
            let encoded = try? self.manager.jsonEncoder.encode(entity)
            return OHHTTPStubsResponse(data: encoded ?? Data(), statusCode: 200, headers: nil)
        }
        manager = builder
            .jsonEncoder { $0.dateEncodingStrategy = .iso8601 }
            .jsonDecoder { $0.dateDecodingStrategy = .iso8601 }
            .build()
        assertNoErrorThrown {
            let dataRequest = try client.request(for: datedEndpoint)
            dataRequest.responseDecodable(client: client, endpoint: datedEndpoint) { (response: Response<DatedEntity>) in
                guard case .success(let result) = response else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(result.value, entity)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5)
    }
    
    func testFailure() {
        let expectation = self.expectation(description: "Expected to find a failure response")
        executeRequest(builder: builder, endpoint: failureEndpoint) { response in
            guard case .failure = response else {
                XCTFail()
                return
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
}

// MARK: - Errors

extension AlamofireLeashTests {
    
    func testDecodingError() {
        let expectation = self.expectation(description: "Expected to find a decoding error")
        let undecodableEndpoint = Endpoint(path: "decoding/error")
        stub(condition: isEndpoint(undecodableEndpoint)) { _ in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
        executeRequest(builder: builder, endpoint: undecodableEndpoint) { response in
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
            dataRequest.responseDecodable(client: client, endpoint: endpoint) { response in
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
