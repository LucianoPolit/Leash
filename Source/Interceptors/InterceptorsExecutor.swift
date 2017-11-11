//
//  InterceptorsExecutor.swift
//  Alamofire
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation

class InterceptorsExecutor<T> {
    
    private var interceptions: [(InterceptorCompletion<T>) -> ()]
    private let completion: (Response<T>) -> ()
    private let finally: ((Response<T>) -> ()) -> ()
    
    init(interceptions: [(InterceptorCompletion<T>) -> ()],
         completion: @escaping (Response<T>) -> (),
         finally: @escaping ((Response<T>) -> ()) -> ()) {
        self.interceptions = interceptions
        self.completion = completion
        self.finally = finally
    }
    
    private func startNext() {
        if (interceptions.isEmpty) {
            finally(completion)
        } else {
            let interception = interceptions.removeFirst()
            interception { result in
                guard let result = result else {
                    startNext()
                    return
                }
                
                completion(result.response)
                if result.finish { startNext() }
            }
        }
    }
    
}
