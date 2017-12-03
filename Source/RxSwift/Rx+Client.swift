//
//  Rx+Client.swift
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

// MARK: - Reactive

extension Client: ReactiveCompatible { }

extension Reactive where Base: Client {
    
    /// Creates and executes the request for the specified endpoint.
    ///
    /// - Parameter endpoint: Contains all the information needed to create the request.
    /// - Parameter type: The type on which the response has to be decoded.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    ///
    /// - Returns: A single with the response.
    public func execute<T: Decodable>(_ endpoint: Endpoint,
                                      type: ReactiveResponse<T>.Type = ReactiveResponse<T>.self,
                                      queue: DispatchQueue? = nil) -> Single<ReactiveResponse<T>> {
        return base.execute(endpoint, queue: queue)
    }
    
    /// Creates and executes the request for the specified endpoint.
    ///
    /// - Parameter endpoint: Contains all the information needed to create the request.
    /// - Parameter type: The type on which the response has to be decoded.
    /// - Parameter queue: The queue on which the completion handler is dispatched.
    ///
    /// - Returns: A single with the value of the response.
    public func execute<T: Decodable>(_ endpoint: Endpoint,
                                      type: T.Type = T.self,
                                      queue: DispatchQueue? = nil) -> Single<T> {
        return base.execute(endpoint, queue: queue).justValue()
    }
    
}

// MARK: - Utils

private extension Client {
    
    func execute<T: Decodable>(_ endpoint: Endpoint, queue: DispatchQueue? = nil) -> Single<ReactiveResponse<T>> {
        do {
            let request = try self.request(for: endpoint)
            return request.rx.responseDecodable(queue: queue, client: self, endpoint: endpoint)
        } catch {
            return .error(Error.encoding(error))
        }
    }
    
}