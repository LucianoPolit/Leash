//
//  ExpensesClient.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash

class ExpensesClient: Client {
    
    func create(_ request: CreateExpenseRequest, completion: @escaping (Response<Expense>) -> Void) {
        execute(endpoint: APIEndpoint.createExpense(request), completion: completion)
    }
    
    func read(completion: @escaping (Response<[Expense]>) -> Void) {
        execute(endpoint: APIEndpoint.getExpenses, completion: completion)
    }
    
    func update(_ request: UpdateExpenseRequest, completion: @escaping (Response<Expense>) -> Void) {
        execute(endpoint: APIEndpoint.updateExpense(request), completion: completion)
    }
    
    func delete(_ expense: String, completion: @escaping (Response<EmptyResponse>) -> Void) {
        execute(endpoint: APIEndpoint.deleteExpense(expense), completion: completion)
    }
    
}
