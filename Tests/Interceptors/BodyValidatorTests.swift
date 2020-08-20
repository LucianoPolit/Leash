//
//  BodyValidatorTests.swift
//  Example
//
//  Created by Luciano Polit on 24/07/2018.
//  Copyright © 2018 Luciano Polit. All rights reserved.
//

import Foundation
import XCTest
@testable import Leash
#if !COCOAPODS
@testable import LeashInterceptors
#endif

class BodyValidatorTests: BaseTestCase {

    let endpoint = Endpoint()
    var interceptor: BodyValidator<PrimitiveEntity>!
    var chain: InterceptorChain<Data>!
    var result: (response: Response<Data>, finish: Bool)?
    var count = 0
    
    override func setUp() {
        super.setUp()
        interceptor = BodyValidator(transform: { Error.some($0) })
        assertNoErrorThrown {
            let dataRequest = try client.request(for: endpoint)
            chain = InterceptorChain(client: client, endpoint: endpoint, request: dataRequest) { result in
                self.result = result
                self.count += 1
            }
        }
    }
    
}

extension BodyValidatorTests {
    
    func testTypeNotFound() {
        let entity = DatedEntity(date: Date())
        let data = (try? JSONEncoder().encode(entity)) ?? Data()
        interceptor.intercept(chain: chain, response: HTTPURLResponse(), data: data)
        XCTAssertEqual(count, 1)
        XCTAssertNil(result)
    }
    
    func testTypeFound() {
        let entity = PrimitiveEntity(first: "123", second: 123, third: true)
        let data = (try? JSONEncoder().encode(entity)) ?? Data()
        interceptor.intercept(chain: chain, response: HTTPURLResponse(), data: data)
        XCTAssertEqual(count, 1)
        XCTAssertNotNil(result)
    }
    
}

extension BodyValidatorTests {
    
    enum Error: Swift.Error {
        case some(PrimitiveEntity)
    }
    
}
