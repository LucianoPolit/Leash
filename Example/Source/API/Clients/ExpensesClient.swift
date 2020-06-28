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
    
    func readAll(
        completion: @escaping APICompletion<[Expense]>
    ) {
        execute(
            .readAll,
            completion: completion
        )
    }
    
    func create(
        _ request: CreateExpenseRequest,
        completion: @escaping APICompletion<Expense>
    ) {
        execute(
            .create(request),
            completion: completion
        )
    }
    
    func update(
        _ request: UpdateExpenseRequest,
        completion: @escaping APICompletion<Expense>
    ) {
        execute(
            .update(request),
            completion: completion
        )
    }
    
    func delete(
        _ expense: String,
        completion: @escaping APICompletion<EmptyResponse>
    ) {
        execute(
            .delete(expense),
            completion: completion
        )
    }
    
}

extension Reactive where Base: ExpensesClient {
    
    func readAll() -> Observable<[Expense]> {
        return execute(base.readAll)
    }
    
    func create(
        _ request: CreateExpenseRequest
    ) -> Observable<Expense> {
        return execute(base.create, with: request)
    }
    
    func update(
        _ request: UpdateExpenseRequest
    ) -> Observable<Expense> {
        return execute(base.update, with: request)
    }
    
    func delete(
        _ expense: String
    ) -> Observable<EmptyResponse> {
        return execute(base.delete, with: expense)
    }
    
}
