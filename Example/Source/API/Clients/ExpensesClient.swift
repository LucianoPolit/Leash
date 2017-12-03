//
//  ExpensesClient.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash
import RxSwift

/// Main client of the project.
class ExpensesClient: Client<ExpensesEndpoint> {
    
    func readAll(completion: @escaping (Response<[Expense]>) -> ()) {
        execute(.readAll, completion: completion)
    }
    
    func create(_ request: CreateExpenseRequest, completion: @escaping (Response<Expense>) -> ()) {
        execute(.create(request), completion: completion)
    }
    
    func update(_ request: UpdateExpenseRequest, completion: @escaping (Response<Expense>) -> ()) {
        execute(.update(request), completion: completion)
    }
    
    func delete(_ expense: String, completion: @escaping (Response<EmptyResponse>) -> ()) {
        execute(.delete(expense), completion: completion)
    }
    
}

extension Reactive where Base: ExpensesClient {
    
    func readAll() -> Single<[Expense]> {
        return execute(.readAll)
    }
    
    func create(_ request: CreateExpenseRequest) -> Single<Expense> {
        return execute(.create(request))
    }
    
    func update(_ request: UpdateExpenseRequest) -> Single<Expense> {
        return execute(.update(request))
    }
    
    func delete(_ expense: String) -> Single<EmptyResponse> {
        return execute(.delete(expense))
    }
    
}
