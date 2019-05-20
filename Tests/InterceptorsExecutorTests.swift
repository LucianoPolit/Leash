//
//  InterceptorsExecutorTests.swift
//  Example
//
//  Created by Luciano Polit on 11/14/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import XCTest
@testable import Leash

class InterceptorsExecutorTests: BaseTestCase { }

// MARK: - Order

extension InterceptorsExecutorTests {
    
    func testOrder() {
        let expectation = self.expectation(description: "Expected to call the completion handler in multiple occasions")
        
        var number = 0
        var expectedNumber = 0
        
        let interceptors = Array(repeating: MockExecutionInterceptor(), count: 5)
        let interceptions: [(@escaping InterceptorCompletion<Data>) -> ()] = interceptors.map { interceptor in
            let num = number
            number += 1
            return { completion in
                self.assertNoErrorThrown {
                    let chain = try self.chain(with: completion)
                    interceptor.intercept(chain: chain)
                    chain.complete(with: Data(count: num), extra: nil, finish: false)
                }
            }
        }
        
        let completion = { (response: Response<Data>) in
            guard case .success(let result) = response else {
                XCTFail()
                return
            }
            XCTAssertEqual(result.value.count, expectedNumber)
            expectedNumber += 1
            
            if expectedNumber == 6 {
                expectation.fulfill()
            }
            
            if expectedNumber > 6 {
                XCTFail()
            }
        }
        
        InterceptorsExecutor(interceptions: interceptions, completion: completion) { completion in
            completion(.success(value: Data(count: number), extra: nil))
        }
        
        waitForExpectations(timeout: 5)
    }
    
}

// MARK: - Finish

extension InterceptorsExecutorTests {
    
    func testFinish() {
        let expectation = self.expectation(description: "Expected to call the completion handler in only one occasion")
        
        var calls = 0

        let interceptors = Array(repeating: MockExecutionInterceptor(), count: 5)
        let interceptions: [(@escaping InterceptorCompletion<Data>) -> ()] = interceptors.map { interceptor in
            return { completion in
                self.assertNoErrorThrown {
                    let chain = try self.chain(with: completion)
                    interceptor.intercept(chain: chain)
                    chain.complete(with: Data(count: 5), extra: nil)
                }
            }
        }

        let completion = { (response: Response<Data>) in
            XCTAssertEqual(calls, 0)
            XCTAssertEqual(response.value?.count, 5)
            calls += 1
            
            if calls == 1 {
                expectation.fulfill()
            }
            
            if calls > 1 {
                XCTFail()
            }
        }
        
        InterceptorsExecutor(interceptions: interceptions, completion: completion) { completion in
            completion(.success(value: Data(), extra: nil))
        }

        waitForExpectations(timeout: 5)
    }
    
}

// MARK: - Others

extension InterceptorsExecutorTests {
    
    func testNoResult() {
        let expectation = self.expectation(description: "Expected to call the completion handler in only one occasion")
        
        var calls = 0

        let interceptors = Array(repeating: MockExecutionInterceptor(), count: 5)
        let interceptions: [(@escaping InterceptorCompletion<Data>) -> ()] = interceptors.map { interceptor in
            return { completion in
                self.assertNoErrorThrown {
                    let chain = try self.chain(with: completion)
                    interceptor.intercept(chain: chain)
                    chain.proceed()
                }
            }
        }
        
        let completion = { (response: Response<Data>) in
            XCTAssertEqual(calls, 0)
            XCTAssertEqual(response.value?.count, 5)
            calls += 1
            
            if calls == 1 {
                expectation.fulfill()
            }
            
            if calls > 1 {
                XCTFail()
            }
        }
        
        InterceptorsExecutor(interceptions: interceptions, completion: completion) { completion in
            completion(.success(value: Data(count: 5), extra: nil))
        }

        waitForExpectations(timeout: 5)
    }
    
}

// MARK: - Utils

private extension InterceptorsExecutorTests {
    
    func chain(with completion: @escaping InterceptorCompletion<Data>) throws -> InterceptorChain<Data> {
        let endpoint = Endpoint()
        let dataRequest = try self.client.request(for: endpoint)
        return InterceptorChain(client: client, endpoint: endpoint, request: dataRequest, completion: completion)
    }
    
}
