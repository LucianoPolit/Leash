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
#if !COCOAPODS
@testable import RxLeash
#endif

// MARK: - Utils

extension ResponseTests {
    
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
