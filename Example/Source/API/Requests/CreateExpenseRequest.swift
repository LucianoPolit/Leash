//
//  CreateExpenseRequest.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation

/// Used to create an expense.
struct CreateExpenseRequest: Encodable {
    
    let userID: String
    let date: Date
    let description: String
    let comment: String
    let amount: Double
    
    enum CodingKeys: String, CodingKey {
        case userID = "user"
        case date
        case description
        case comment
        case amount
    }

}
