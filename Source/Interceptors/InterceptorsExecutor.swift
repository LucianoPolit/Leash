//
//  InterceptorsExecutor.swift
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

/// Responsible for executing the interceptors in a queue order (asynchronously).
/// After all the interceptors are executed, the finally handler is called.
/// In case that any of the interceptors requests to finish the operation, no more interceptors are called (neither the finally handler).
class InterceptorsExecutor {
    
    private var interceptions: [(@escaping InterceptorCompletion) -> ()]
    private let completion: (Response<Data>) -> ()
    private let finally: (@escaping (Response<Data>) -> ()) -> ()
    
    @discardableResult
    init(interceptions: [(@escaping InterceptorCompletion) -> ()],
         completion: @escaping (Response<Data>) -> (),
         finally: @escaping (@escaping (Response<Data>) -> ()) -> ()) {
        self.interceptions = interceptions
        self.completion = completion
        self.finally = finally
        startNext()
    }
    
    private func startNext() {
        if (interceptions.isEmpty) {
            finally(completion)
        } else {
            let interception = interceptions.removeFirst()
            interception { [weak self] result in
                guard let `self` = self else { return }
                guard let result = result else { return self.startNext() }
                
                self.completion(result.response)
                if !result.finish {
                    self.startNext()
                }
            }
        }
    }
    
}
