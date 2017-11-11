//
//  MainViewController.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import UIKit
import Leash

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        
        let userID = "59d79954ae29646064f8ecc9"
        
        // MARK: - Read
        
        API.shared.expenses.read(completion: Logger.shared.logResponse)
        
        // MARK: - Create
        
        let createRequest = CreateExpenseRequest(userID: userID,
                                                 date: Date(),
                                                 description: "desc",
                                                 comment: "com",
                                                 amount: 50)
        API.shared.expenses.create(createRequest, completion: Logger.shared.logResponse)
        
        // MARK: - Update
        
        let updateRequest = UpdateExpenseRequest(id: "any",
                                                 userID: userID,
                                                 date: Date(),
                                                 description: "desc",
                                                 comment: "com",
                                                 amount: 50)
        API.shared.expenses.update(updateRequest, completion: Logger.shared.logResponse)
        
        // MARK: - Delete
        
        API.shared.expenses.delete("another", completion: Logger.shared.logResponse)
        
    }
    
}
