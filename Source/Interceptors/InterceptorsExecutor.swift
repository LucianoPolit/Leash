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
/// In case that any of the interceptors requests to finish the operation,
/// no more interceptors are called (neither the finally handler).
/// The completion handler is always dispatched on the specified queue.
class InterceptorsExecutor<T> {
    
    typealias Interception = (@escaping InterceptorCompletion<T>) -> ()
    typealias Completion = (Response<T>) -> ()
    typealias Finally = (@escaping (Response<T>) -> ()) -> ()
    
    fileprivate let operationQueue = OperationQueue()
    fileprivate let queue: DispatchQueue
    fileprivate var interceptions: [Interception]
    fileprivate let completion: Completion
    fileprivate let finally: Finally
    
    @discardableResult
    init(queue: DispatchQueue? = nil,
         interceptions: [Interception],
         completion: @escaping Completion,
         finally: @escaping Finally) {
        self.queue = queue ?? .main
        self.interceptions = interceptions
        self.completion = completion
        self.finally = finally
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .utility
        start()
    }
    
    private func start() {
        while !interceptions.isEmpty {
            let interception = interceptions.removeFirst()
            let operation = InterceptionOperation(interception: interception,
                                                  completionHandler: completionHandler,
                                                  finishHandler: finishHandler)
            operationQueue.addOperation(operation)
        }
        
        operationQueue.addOperation {
            self.finallyHandler()
        }
    }
    
}

// MARK: - Utils

private extension InterceptorsExecutor {
    
    func dispatch(_ block: @escaping () -> ()) {
        queue.async(execute: block)
    }
    
    func finallyHandler() {
        dispatch {
            self.finally(self.completion)
        }
    }
    
    func completionHandler(response: Response<T>) {
        dispatch {
            self.completion(response)
        }
    }
    
    func finishHandler() {
        operationQueue.cancelAllOperations()
    }
    
}

private class InterceptionOperation<T>: AsynchronousOperation {
    
    typealias FinishHandler = () -> ()
    
    let interception: InterceptorsExecutor<T>.Interception
    let completionHandler: InterceptorsExecutor<T>.Completion
    let finishHandler: FinishHandler
    
    init(interception: @escaping InterceptorsExecutor<T>.Interception,
         completionHandler: @escaping InterceptorsExecutor<T>.Completion,
         finishHandler: @escaping FinishHandler) {
        self.interception = interception
        self.completionHandler = completionHandler
        self.finishHandler = finishHandler
    }
    
    override func main() {
        guard !isCancelled else { return }
        
        state = .executing
        
        interception { result in
            defer { self.state = .finished }
            guard let result = result else { return }
            
            self.completionHandler(result.response)
            
            if result.finish {
                self.finishHandler()
            }
        }
    }
    
}

private class AsynchronousOperation: Operation {
    
    var state: State = .ready {
        willSet {
            willChangeValue(forKey: state.key)
            willChangeValue(forKey: newValue.key)
        }
        didSet {
            didChangeValue(forKey: oldValue.key)
            didChangeValue(forKey: state.key)
        }
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    enum State: String {
        
        case ready
        case executing
        case finished
        
        var key: String {
            return "is" + rawValue.capitalized
        }
        
    }
    
}
