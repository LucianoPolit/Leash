//
//  Rx+Response+Tests.swift
//  Example
//
//  Created by Luciano Polit on 12/3/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import RxSwift
import XCTest
@testable import Leash

// MARK: - Utils

extension ResponseTests {
    
    func testRxSingleJustValue() {
        let response = ReactiveResponse(123, nil)
        let single = Single.just(response)
        single.justValue()
            .subscribe(onSuccess: { value in
                XCTAssertEqual(response.value, value)
            })
            .dispose()
    }
    
    func testRxObservableJustValue() {
        let response = ReactiveResponse(123, nil)
        let observable = Observable.just(response)
        observable.justValue()
            .subscribe(onNext: { value in
                XCTAssertEqual(response.value, value)
            })
            .dispose()
    }
    
}
