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

class InterceptorsExecutorTests: BaseTestCase {
    
    typealias T = Int
    
}

// MARK: - Order

extension InterceptorsExecutorTests {
    
    func testOrder() {
        var number = 0
        var expectedNumber = 0
        
        let interceptors = Array(repeating: MockExecutionInterceptor<T>(), count: 5)
        let queue: [(@escaping InterceptorCompletion<T>) -> ()] = interceptors.map { interceptor in
            let num = number
            number += 1
            return { completion in
                self.assertNoErrorThrown {
                    let chain = try self.chain(with: completion)
                    interceptor.intercept(chain: chain)
                    chain.complete(with: num, extra: nil, finish: false)
                }
            }
        }
        
        let completion = { (response: Response<T>) in
            guard case .success(let result) = response else {
                XCTFail()
                return
            }
            XCTAssertEqual(result.value, expectedNumber)
            expectedNumber += 1
        }
        
        InterceptorsExecutor(queue: queue, completion: completion) { completion in
            completion(.success(value: number, extra: nil))
        }
        
        XCTAssertEqual(expectedNumber, number + 1)
        XCTAssertEqual(expectedNumber, 6)
    }
    
}

// MARK: - Finish

extension InterceptorsExecutorTests {
    
    func testFinish() {
        var calls = 0
        
        let interceptors = Array(repeating: MockExecutionInterceptor<T>(), count: 5)
        let queue: [(@escaping InterceptorCompletion<T>) -> ()] = interceptors.map { interceptor in
            return { completion in
                self.assertNoErrorThrown {
                    let chain = try self.chain(with: completion)
                    interceptor.intercept(chain: chain)
                    chain.complete(with: 0, extra: nil)
                }
            }
        }
        
        let completion = { (response: Response<T>) in
            XCTAssertEqual(calls, 0)
            calls += 1
        }
        
        InterceptorsExecutor(queue: queue, completion: completion) { completion in
            completion(.success(value: 0, extra: nil))
        }
        
        XCTAssertEqual(calls, 1)
    }
    
}

// MARK: - Others

extension InterceptorsExecutorTests {
    
    func testNoResult() {
        var calls = 0
        
        let interceptors = Array(repeating: MockExecutionInterceptor<T>(), count: 5)
        let queue: [(@escaping InterceptorCompletion<T>) -> ()] = interceptors.map { interceptor in
            return { completion in
                self.assertNoErrorThrown {
                    let chain = try self.chain(with: completion)
                    interceptor.intercept(chain: chain)
                    chain.proceed()
                }
            }
        }
        
        let completion = { (response: Response<T>) in
            XCTAssertEqual(calls, 0)
            calls += 1
        }
        
        InterceptorsExecutor(queue: queue, completion: completion) { completion in
            completion(.success(value: 0, extra: nil))
        }
        
        XCTAssertEqual(calls, 1)
    }
    
}

// MARK: - Utils

private extension InterceptorsExecutorTests {
    
    func chain(with completion: @escaping InterceptorCompletion<T>) throws -> InterceptorChain<T> {
        let endpoint = Endpoint()
        let dataRequest = try self.client.request(for: endpoint)
        return InterceptorChain(client: client, endpoint: endpoint, request: dataRequest, completion: completion)
    }
    
}
