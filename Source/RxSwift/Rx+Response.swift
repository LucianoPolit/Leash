//
//  Rx+Response.swift
//
//  Copyright (c) 2017 Luciano Polit <lucianopolit@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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

// MARK: - Utils

extension PrimitiveSequence where Trait == SingleTrait, Element: ReactiveResponseType {
    
    /// Transforms the element on its value.
    public func justValue() -> Single<Element.Value> {
        return map { $0.value }
    }
    
}

extension Observable where Element: ReactiveResponseType {
    
    /// Transforms the element on its value.
    public func justValue() -> Observable<Element.Value> {
        return map { $0.value }
    }
    
}
