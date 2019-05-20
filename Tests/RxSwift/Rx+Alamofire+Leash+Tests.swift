//
//  Rx+Alamofire+Leash+Tests.swift
//  Example
//
//  Created by Luciano Polit on 12/3/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import XCTest
import OHHTTPStubs
@testable import Leash

// MARK: - Interceptors

extension AlamofireLeashTests {
    
    func testRxCallsOnSuccess() {
        let expectation = self.expectation(description: "Expected to call all the interceptors")
        let disposeBag = DisposeBag()
        let executionInterceptor = MockExecutionInterceptor()
        let successInterceptor = MockSuccessInterceptor()
        let completionInterceptor = MockCompletionInterceptor()
        let serializationInterceptor = MockSerializationInterceptor<T>()
        let builder = self.builder
            .add(interceptor: executionInterceptor)
            .add(interceptor: successInterceptor)
            .add(interceptor: completionInterceptor)
            .add(interceptor: serializationInterceptor)
        
        rx.testCallsInterceptors(dataInterceptors: [executionInterceptor, successInterceptor, completionInterceptor],
                                 lastInterceptors: [serializationInterceptor]) {
                                    expectation.fulfill()
        }
        rx.executeRequest(builder: builder, endpoint: successEndpoint)?
            .subscribe()
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5)
    }
    
    func testRxCallsOnFailure() {
        let expectation = self.expectation(description: "Expected to call all the interceptors")
        let disposeBag = DisposeBag()
        let executionInterceptor = MockExecutionInterceptor()
        let failureInterceptor = MockFailureInterceptor()
        let completionInterceptor = MockCompletionInterceptor()
        let serializationInterceptor = MockSerializationInterceptor<T>()
        let builder = self.builder
            .add(interceptor: executionInterceptor)
            .add(interceptor: failureInterceptor)
            .add(interceptor: completionInterceptor)
            .add(interceptor: serializationInterceptor)

        rx.testCallsInterceptors(dataInterceptors: [executionInterceptor, failureInterceptor, completionInterceptor],
                                 lastInterceptors: [serializationInterceptor]) {
                                    expectation.fulfill()
        }
        rx.executeRequest(builder: builder, endpoint: failureEndpoint)?
            .subscribe()
            .disposed(by: disposeBag)
        
        waitForExpectations(timeout: 5)
    }
    
}

// MARK: - Response

extension AlamofireLeashTests {
    
    func testRxSerializer() {
        let expectation = self.expectation(description: "Expected to find a success response")
        let disposeBag = DisposeBag()
        assertNoErrorThrown {
            let endpoint = successEndpoint
            let dataRequest = try client.request(for: endpoint)
            let serializer = JSONResponseSerializer()
            dataRequest.rx.response(client: client, endpoint: endpoint, serializer: serializer)
                .subscribe(onSuccess: { _ in
                    expectation.fulfill()
                })
                .disposed(by: disposeBag)
        }
        waitForExpectations(timeout: 5)
    }
    
    func testRxDecodable() {
        let expectation = self.expectation(description: "Expected to find a success response")
        let disposeBag = DisposeBag()
        rx.executeRequest(builder: builder, endpoint: successEndpoint)?
            .subscribe(onSuccess: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        waitForExpectations(timeout: 5)
    }

}

// MARK: - Errors

extension AlamofireLeashTests {
    
    func testRxDecodingError() {
        let expectation = self.expectation(description: "Expected to find a decoding error")
        let disposeBag = DisposeBag()
        let undecodableEndpoint = Endpoint(path: "decoding/error")
        stub(condition: isEndpoint(undecodableEndpoint)) { _ in
            return OHHTTPStubsResponse(jsonObject: ["some": "some"], statusCode: 200, headers: nil)
        }
        rx.executeRequest(builder: builder, endpoint: undecodableEndpoint)?
            .subscribe(onError: { error in
                guard case Leash.Error.decoding = error else {
                    XCTFail()
                    return
                }
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        waitForExpectations(timeout: 5)
    }
    
}

// MARK: - Utils

private extension Reactive where Base: AlamofireLeashTests {
    
    func testCallsInterceptors<T: MockInterceptor>(dataInterceptors: [MockDataInterceptor],
                                                   lastInterceptors: [T],
                                                   completion: (() -> ())?) {
        var calls = 0
        let total = dataInterceptors.count + lastInterceptors.count
        dataInterceptors.forEach {
            $0.completion = {
                $0?.proceed()
                calls += 1
            }
        }
        lastInterceptors.forEach {
            $0.completion = {
                $0?.proceed()
                calls += 1
                if calls == total {
                    completion?()
                }
            }
        }
    }
    
    func executeRequest(builder: Manager.Builder, endpoint: Endpoint) -> Single<ReactiveResponse<Base.T>>? {
        var single: Single<ReactiveResponse<Base.T>>?
        base.manager = builder.build()
        base.assertNoErrorThrown {
            let dataRequest = try base.client.request(for: endpoint)
            single = dataRequest.rx.responseDecodable(client: base.client, endpoint: endpoint)
        }
        return single
    }
    
}

protocol MockDataInterceptor: class {
    var completion: ((InterceptorChain<Data>?) -> ())? { get set }
    var interceptCalled: Bool { get }
    var interceptParameterChain: InterceptorChain<Data>? { get }
}

extension MockExecutionInterceptor: MockDataInterceptor { }
extension MockFailureInterceptor: MockDataInterceptor { }
extension MockSuccessInterceptor: MockDataInterceptor { }
extension MockCompletionInterceptor: MockDataInterceptor { }
