//
//  CacheControllerTests.swift
//  Example
//
//  Created by Luciano Polit on 24/07/2018.
//  Copyright © 2018 Luciano Polit. All rights reserved.
//

import Foundation
import Alamofire
import XCTest
@testable import Leash
#if !COCOAPODS
@testable import LeashInterceptors
#endif

class CacheControllerTests: BaseTestCase {
    
    let entity = PrimitiveEntity(first: "some", second: 123, third: true)
    let endpoint = Endpoint(path: "/some/")
    let dataStore = MockDataStore()
    let policy = MockCachePolicy()
    var interceptor: CacheInterceptor!
    var chain: InterceptorChain<Data>!
    var sChain: InterceptorChain<PrimitiveEntity>!
    var result: (response: Response<Data>, finish: Bool)?
    var sResult: (response: Response<PrimitiveEntity>, finish: Bool)?
    var count = 0
    
    override func setUp() {
        super.setUp()
        dataStore.dataReturn = (try? JSONEncoder().encode(entity)) ?? Data()
        interceptor = CacheInterceptor(dataStore: dataStore)
        interceptor.register(policy: policy, to: endpoint.path)
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

// MARK: - Route & Policies

extension CacheControllerTests {
    
    func testRouteAndPolicies() {
        interceptor.register(policy: MockCachePolicy(), to: "/some/[0-9]*/other/")
        interceptor.register(policy: MockCachePolicy(), to: "/some/asd/other/")
        let endpoint1 = Endpoint(path: "/some/123/other/", method: .get, parameters: nil)
        let endpoint2 = Endpoint(path: "/some/asd/other/", method: .get, parameters: nil)
        let endpoint3 = Endpoint(path: "/some/qwe/other/", method: .get, parameters: nil)
        let endpoint4 = Endpoint(path: "/some/123/other/", method: .post, parameters: nil)
        XCTAssertNotNil(interceptor.policy(for: endpoint1))
        XCTAssertNotNil(interceptor.policy(for: endpoint2))
        XCTAssertNil(interceptor.policy(for: endpoint3))
        XCTAssertNil(interceptor.policy(for: endpoint4))
    }
    
}

// MARK: - Execution

extension CacheControllerTests {
    
    func testExecution() {
        policy.shouldCacheBeforeExecutionReturn = true
        policy.shouldFinishAfterCacheReturn = false
        interceptor.intercept(chain: chain)
        XCTAssertTrue(policy.shouldCacheBeforeExecutionCalled)
        XCTAssertTrue(policy.shouldFinishAfterCacheCalled)
        XCTAssertEqual(count, 1)
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?.response.value)
        XCTAssertFalse(result?.finish ?? false)
    }
    
    func testExecutionCallsDataStore() {
        policy.shouldCacheBeforeExecutionReturn = true
        interceptor.intercept(chain: chain)
        XCTAssertTrue(dataStore.dataCalled)
        XCTAssertEqual(dataStore.dataParameterEndpoint?.path, endpoint.path)
        XCTAssertEqual(dataStore.dataReturn, result?.response.value)
    }
    
    func testExecutionWithFinish() {
        policy.shouldCacheBeforeExecutionReturn = true
        policy.shouldFinishAfterCacheReturn = true
        interceptor.intercept(chain: chain)
        XCTAssertTrue(result?.finish ?? false)
    }
    
    func testNoExecution() {
        policy.shouldCacheBeforeExecutionReturn = false
        interceptor.intercept(chain: chain)
        XCTAssertTrue(policy.shouldCacheBeforeExecutionCalled)
        XCTAssertFalse(policy.shouldFinishAfterCacheCalled)
        XCTAssertEqual(count, 1)
        XCTAssertNil(result)
    }
    
}

// MARK: - Completion

extension CacheControllerTests {
    
    func testCompletion() {
        policy.shouldCacheOnErrorReturn = true
        policy.shouldFinishAfterCacheReturn = false
        interceptor.intercept(chain: chain, response: .failure(Leash.Error.unknown))
        XCTAssertTrue(policy.shouldCacheOnErrorCalled)
        XCTAssertTrue(policy.shouldFinishAfterCacheCalled)
        XCTAssertEqual(count, 1)
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?.response.value)
        XCTAssertFalse(result?.finish ?? false)
    }
    
    func testCompletionCallsDataStore() {
        policy.shouldCacheOnErrorReturn = true
        interceptor.intercept(chain: chain, response: .failure(Leash.Error.unknown))
        XCTAssertTrue(dataStore.dataCalled)
        XCTAssertEqual(dataStore.dataParameterEndpoint?.path, endpoint.path)
        XCTAssertEqual(dataStore.dataReturn, result?.response.value)
    }
    
    func testCompletionWithFinish() {
        policy.shouldCacheOnErrorReturn = true
        policy.shouldFinishAfterCacheReturn = true
        interceptor.intercept(chain: chain, response: .failure(Leash.Error.unknown))
        XCTAssertTrue(result?.finish ?? false)
    }
    
    func testNoCompletion() {
        policy.shouldCacheOnErrorReturn = false
        interceptor.intercept(chain: chain, response: .failure(Leash.Error.unknown))
        XCTAssertTrue(policy.shouldCacheOnErrorCalled)
        XCTAssertFalse(policy.shouldFinishAfterCacheCalled)
        XCTAssertEqual(count, 1)
        XCTAssertNil(result)
    }
    
    func testNoCompletionOnSuccess() {
        interceptor.intercept(chain: chain, response: .success(value: Data(), extra: nil))
        XCTAssertFalse(policy.shouldCacheOnErrorCalled)
        XCTAssertFalse(policy.shouldFinishAfterCacheCalled)
        XCTAssertEqual(count, 1)
        XCTAssertNil(result)
    }
    
}

// MARK: - Serialization

extension CacheControllerTests {
    
    func testSerialization() {
        policy.shouldSaveAfterSuccessReturn = true
        interceptor.intercept(chain: sChain,
                              response: .success(value: Data(), extra: nil),
                              result: .success(entity),
                              serializer: DecodableResponseSerializer())
        XCTAssertTrue(policy.shouldSaveAfterSuccessCalled)
        XCTAssertEqual(count, 1)
        XCTAssertNil(result)
    }
    
    func testSerializationCallsDataStore() {
        let data = Data()
        policy.shouldSaveAfterSuccessReturn = true
        interceptor.intercept(chain: sChain,
                              response: .success(value: data, extra: nil),
                              result: .success(entity),
                              serializer: DecodableResponseSerializer())
        XCTAssertTrue(dataStore.saveCalled)
        XCTAssertEqual(dataStore.saveParameterData, data)
    }
    
    func testNoSerialization() {
        policy.shouldSaveAfterSuccessReturn = false
        interceptor.intercept(chain: sChain,
                              response: .success(value: Data(), extra: nil),
                              result: .success(entity),
                              serializer: DecodableResponseSerializer())
        XCTAssertTrue(policy.shouldSaveAfterSuccessCalled)
        XCTAssertEqual(count, 1)
        XCTAssertNil(result)
        XCTAssertFalse(dataStore.saveCalled)
    }
    
    func testNoSerializationOnCacheExtra() {
        policy.shouldSaveAfterSuccessReturn = true
        interceptor.intercept(chain: sChain,
                              response: .success(value: Data(), extra: CacheExtra()),
                              result: .success(entity),
                              serializer: DecodableResponseSerializer())
        XCTAssertFalse(policy.shouldSaveAfterSuccessCalled)
        XCTAssertEqual(count, 1)
        XCTAssertNil(result)
        XCTAssertFalse(dataStore.saveCalled)
    }
    
}

// MARK: - Policies

extension CacheControllerTests {
    
    func testCacheAndRenew() {
        let policy = CachePolicy.CacheAndRenew()
        XCTAssertTrue(policy.shouldCacheBeforeExecution())
        XCTAssertTrue(policy.shouldSaveAfterSuccess())
        XCTAssertFalse(policy.shouldFinishAfterCache())
        XCTAssertFalse(policy.shouldCacheOnError(Leash.Error.unknown))
    }
    
    func testCacheOnlyOnError() {
        let policy = CachePolicy.CacheOnlyOnError()
        XCTAssertFalse(policy.shouldCacheBeforeExecution())
        XCTAssertTrue(policy.shouldSaveAfterSuccess())
        XCTAssertTrue(policy.shouldFinishAfterCache())
        XCTAssertTrue(policy.shouldCacheOnError(Leash.Error.unknown))
    }
    
}

// MARK: - Utils

class MockDataStore: DataStore {
    
    var dataCalled = false
    var dataParameterEndpoint: Leash.Endpoint?
    var dataReturn: Data?
    func data(for endpoint: Leash.Endpoint) -> Data? {
        dataCalled = true
        dataParameterEndpoint = endpoint
        return dataReturn
    }
    
    var saveCalled = false
    var saveParameterData: Data?
    var saveParameterEndpoint: Leash.Endpoint?
    func save(_ data: Data, for endpoint: Leash.Endpoint) {
        saveCalled = true
        saveParameterData = data
        saveParameterEndpoint = endpoint
    }
    
}

class MockCachePolicy: CachePolicyProtocol {
    
    var shouldCacheBeforeExecutionCalled = false
    var shouldCacheBeforeExecutionReturn = false
    func shouldCacheBeforeExecution() -> Bool {
        shouldCacheBeforeExecutionCalled = true
        return shouldCacheBeforeExecutionReturn
    }
    
    var shouldCacheOnErrorCalled = false
    var shouldCacheOnErrorParameterError: Swift.Error?
    var shouldCacheOnErrorReturn = false
    func shouldCacheOnError(_ error: Swift.Error) -> Bool {
        shouldCacheOnErrorCalled = true
        shouldCacheOnErrorParameterError = error
        return shouldCacheOnErrorReturn
    }
    
    var shouldSaveAfterSuccessCalled = false
    var shouldSaveAfterSuccessReturn = false
    func shouldSaveAfterSuccess() -> Bool {
        shouldSaveAfterSuccessCalled = true
        return shouldSaveAfterSuccessReturn
    }
    
    var shouldFinishAfterCacheCalled = false
    var shouldFinishAfterCacheReturn = false
    func shouldFinishAfterCache() -> Bool {
        shouldFinishAfterCacheCalled = true
        return shouldFinishAfterCacheReturn
    }
    
}
