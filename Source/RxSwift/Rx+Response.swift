//
//  Rx+Response.swift
//
//  Copyright (c) 2017-2020 Luciano Polit <lucianopolit@gmail.com>
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

// MARK: - Reactive

/// Type of the response.
public protocol ReactiveResponseType {
    /// Type of the value.
    associatedtype Value
    /// The value of the response.
    var value: Value { get }
    /// The extra information of the response.
    var extra: Any? { get }
}

/// Represents a successful response of a request.
public struct ReactiveResponse<Value>: ReactiveResponseType {
    
    /// The value of the response.
    public let value: Value
    /// The extra information of the response.
    public let extra: Any?
    
    /// Initializes and returns a newly allocated object with the specified parameters.
    init(_ value: Value, _ extra: Any?) {
        self.value = value
        self.extra = extra
    }
    
}

// MARK: - Utils

extension Observable where Element: ReactiveResponseType {
    
    /// Transforms the element on its value.
    public func justValue() -> Observable<Element.Value> {
        return map { $0.value }
    }
    
}

extension Event {
    
    static func fromResponse(_ response: Response<Element>) -> Event<ReactiveResponse<Element>> {
        switch response {
        case .success(let value, let extra):
            return .next(ReactiveResponse(value, extra))
        case .failure(let error):
            return .error(error)
        }
    }
    
}
