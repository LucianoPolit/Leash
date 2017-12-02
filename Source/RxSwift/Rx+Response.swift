//
//  Rx+Response.swift
//  Alamofire
//
//  Created by Luciano Polit on 12/1/17.
//

import Foundation
import RxSwift

public protocol ReactiveResponseType {
    associatedtype Value
    var value: Value { get }
    var extra: Any? { get }
}

public struct ReactiveResponse<Value>: ReactiveResponseType {
    
    public let value: Value
    public let extra: Any?
    
    init(_ value: Value, _ extra: Any?) {
        self.value = value
        self.extra = extra
    }
    
}

extension Observable where Element: ReactiveResponseType {
    
    public func withoutExtra() -> Observable<Element.Value> {
        return map { $0.value }
    }
    
}
