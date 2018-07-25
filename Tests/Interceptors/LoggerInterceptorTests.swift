//
//  LoggerInterceptorTests.swift
//  Example
//
//  Created by Luciano Polit on 24/07/2018.
//  Copyright © 2018 Luciano Polit. All rights reserved.
//

import Foundation
import XCTest
@testable import Leash

class LoggerInterceptorTests: BaseTestCase {
    
    let dash = "-"
    let endpoint = Endpoint()
    let logger = MockLogger()
    var interceptor: LoggerInterceptor!
    var chain: InterceptorChain<Data>!
    var sChain: InterceptorChain<Int>!
    var result: (response: Response<Data>, finish: Bool)?
    var sResult: (response: Response<Int>, finish: Bool)?
    var count = 0
    
    override func setUp() {
        super.setUp()
        interceptor = LoggerInterceptor(logger: logger)
        assertNoErrorThrown {
            let dataRequest = try client.request(for: endpoint)
            chain = InterceptorChain(client: client, endpoint: endpoint, request: dataRequest) { result in
                self.result = result
                self.count += 1
            }
            sChain = InterceptorChain(client: client, endpoint: endpoint, request: dataRequest) { result in
                self.sResult = result
                self.count += 1
            }
        }
    }
    
}

// MARK: - Execution

extension LoggerInterceptorTests {
    
    func testExecution() {
        interceptor.execution = (pre: dash, post: dash)
        interceptor.intercept(chain: chain)
        assertResultAndCount()
        assertValues()
        assertNoError()
    }
    
}

// MARK: - Completion

extension LoggerInterceptorTests {
    
    func testCompletionSuccess() {
        interceptor.success = (pre: dash, post: dash)
        interceptor.intercept(chain: chain, response: .success(value: Data(), extra: nil))
        assertResultAndCount()
        assertValues()
        assertNoError()
    }
    
    func testCompletionFailure() {
        interceptor.failure = (pre: dash, post: dash)
        interceptor.intercept(chain: chain, response: .failure(Leash.Error.unknown))
        assertResultAndCount()
        assertValues()
        assertError()
    }
    
}

// MARK: - Serialization

extension LoggerInterceptorTests {
    
    func testSerializationSuccess() {
        interceptor.serializationSuccess = (pre: dash, post: dash)
        interceptor.intercept(chain: sChain,
                              response: .success(value: Data(), extra: nil),
                              result: .success(0),
                              serializer: DataRequest.decodableResponseSerializer(jsonDecoder: JSONDecoder()))
        assertResultAndCount()
        assertValues()
        assertNoError()
    }
    
    func testSerializationDecodingFailure() {
        interceptor.serializationFailure = (pre: dash, post: dash)
        interceptor.intercept(chain: sChain,
                              response: .success(value: Data(), extra: nil),
                              result: .failure(Leash.Error.decoding(Leash.Error.unknown)),
                              serializer: DataRequest.decodableResponseSerializer(jsonDecoder: JSONDecoder()))
        assertResultAndCount()
        assertValues()
        assertError(.decoding(Leash.Error.unknown))
    }
    
    func testSerializationNotDecodingFailure() {
        interceptor.serializationFailure = (pre: dash, post: dash)
        interceptor.intercept(chain: sChain,
                              response: .success(value: Data(), extra: nil),
                              result: .failure(Leash.Error.unknown),
                              serializer: DataRequest.decodableResponseSerializer(jsonDecoder: JSONDecoder()))
        assertResultAndCount()
        assertNoValues()
        assertNoError()
    }
    
}

// MARK: - Other

extension LoggerInterceptorTests {
    
    func testOther() {
        let interceptor = LoggerInterceptor()
        interceptor.log(chain: chain, pre: "-", post: "-")
        interceptor.log(error: Leash.Error.unknown)
    }
    
}

// MARK: - Utils

private extension LoggerInterceptorTests {
    
    func assertValues() {
        XCTAssertTrue(logger.logMessageCalled)
        XCTAssertEqual(logger.logMessageParameterMessage, message(chain: chain, pre: dash, post: dash))
    }
    
    func assertNoValues() {
        XCTAssertFalse(logger.logMessageCalled)
    }
    
    func assertError(_ error: Leash.Error = .unknown) {
        XCTAssertTrue(logger.logErrorCalled)
        XCTAssertEqual(logger.logErrorParameterError?.localizedDescription, error.localizedDescription)
    }
    
    func assertNoError() {
        XCTAssertFalse(logger.logErrorCalled)
    }
    
    func assertResultAndCount() {
        XCTAssertNil(result)
        XCTAssertEqual(count, 1)
    }
    
}

private extension LoggerInterceptorTests {
    
    func message<T>(chain: InterceptorChain<T>, pre: String, post: String) -> String {
        guard let request = chain.request.request,
            let method = request.httpMethod,
            let url = request.url?.absoluteString else { return "" }
        return "\(pre) \(method) \(url) \(post)"
    }
    
}

class MockLogger: Logger {
    
    var logMessageCalled = false
    var logMessageParameterMessage: String?
    func log(message: String) {
        logMessageCalled = true
        logMessageParameterMessage = message
    }
    
    var logErrorCalled = false
    var logErrorParameterError: Swift.Error?
    func log(error: Swift.Error) {
        logErrorCalled = true
        logErrorParameterError = error
    }
    
}
