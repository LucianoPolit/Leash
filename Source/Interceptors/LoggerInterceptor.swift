//
//  LoggerInterceptor.swift
//
//  Copyright (c) 2017-2019 Luciano Polit <lucianopolit@gmail.com>
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

public protocol Logger {
    func log(message: String)
    func log(error: Swift.Error)
}

public class Printer: Logger {
    
    public init() { }
    
    public func log(message: String) {
        print(message)
    }
    
    public func log(error: Swift.Error) {
        print(error)
    }
    
}

open class LoggerInterceptor {
    
    public let logger: Logger
    public var execution = (pre: "👉👉👉", post: "")
    public var failure = (pre: "✖✖✖", post: "")
    public var success = (pre: "✔✔✔", post: "")
    public var serializationFailure = (pre: "✖✖✖", post: "(Serialization)")
    public var serializationSuccess = (pre: "✔✔✔", post: "(Serialization)")
    
    public init(logger: Logger = Printer()) {
        self.logger = logger
    }
    
    open func log<T>(chain: InterceptorChain<T>, pre: String, post: String) {
        guard let request = chain.request.request,
            let method = request.httpMethod,
            let url = request.url?.absoluteString else { return }
        logger.log(message: "\(pre) \(method) \(url) \(post)")
    }
    
    open func log(error: Swift.Error) {
        logger.log(error: error)
    }
    
}

extension LoggerInterceptor: ExecutionInterceptor {
    
    public func intercept(chain: InterceptorChain<Data>) {
        defer { chain.proceed() }
        log(chain: chain, pre: execution.pre, post: execution.post)
    }
    
}

extension LoggerInterceptor: CompletionInterceptor {
    
    public func intercept(chain: InterceptorChain<Data>, response: Response<Data>) {
        defer { chain.proceed() }
        switch response {
        case .success:
            log(chain: chain, pre: success.pre, post: success.post)
        case .failure(let error):
            log(chain: chain, pre: failure.pre, post: failure.post)
            log(error: error)
        }
    }
    
}

extension LoggerInterceptor: SerializationInterceptor {
    
    public func intercept<T: DataResponseSerializerProtocol>(chain: InterceptorChain<T.SerializedObject>,
                                                             response: Response<Data>,
                                                             result: Result<T.SerializedObject>,
                                                             serializer: T) {
        defer { chain.proceed() }
        switch result {
        case .success:
            log(chain: chain, pre: serializationSuccess.pre, post: serializationSuccess.post)
        case .failure(let error):
            guard case Error.decoding = error else { return }
            log(chain: chain, pre: serializationFailure.pre, post: serializationFailure.post)
            log(error: error)
        }
    }
    
}
