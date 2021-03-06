//
//  BodyValidator.swift
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
#if !COCOAPODS
import Leash
#endif

open class BodyValidator<T: Decodable> {
    
    public let transform: (T) -> Swift.Error
    
    public init(
        type: T.Type = T.self,
        transform: @escaping (T) -> Swift.Error
    ) {
        self.transform = transform
    }
    
}

extension BodyValidator: SuccessInterceptor {
    
    public func intercept(
        chain: InterceptorChain<Data>,
        response: HTTPURLResponse,
        data: Data
    ) {
        defer { chain.proceed() }
        guard let value = try? chain.client.manager.jsonDecoder.decode(T.self, from: data) else { return }
        chain.complete(
            with: transform(value)
        )
    }
    
}
