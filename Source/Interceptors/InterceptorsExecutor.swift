//
//  InterceptorsExecutor.swift
//  Alamofire
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation

class InterceptorsExecutor<T> {
    
    private var queue: [(@escaping InterceptorCompletion<T>) -> ()]
    private let completion: (Response<T>) -> ()
    private let finally: (@escaping (Response<T>) -> ()) -> ()
    
    @discardableResult
    init(queue: [(@escaping InterceptorCompletion<T>) -> ()],
         completion: @escaping (Response<T>) -> (),
         finally: @escaping (@escaping (Response<T>) -> ()) -> ()) {
        self.queue = queue
        self.completion = completion
        self.finally = finally
        startNext()
    }
    
    private func startNext() {
        if (queue.isEmpty) {
            finally(completion)
        } else {
            let interception = queue.removeFirst()
            interception { [weak self] result in
                guard let result = result else {
                    self?.startNext()
                    return
                }
                
                self?.completion(result.response)
                if !result.finish { self?.startNext() }
            }
        }
    }
    
}
