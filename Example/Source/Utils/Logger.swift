//
//  Logger.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash

/// Defines how something should be logged.
enum LogFlag {
    case debug
    case error
    case warning
}

/// The logger of the project.
/// Actually, it only prints the specified information, but it could be changed to save some reports.
class Logger {
    
    // MARK: - Properties
    
    static let shared = Logger()
    
    // MARK: - Methods
    
    func log(_ message: Any, flag: LogFlag) {
        var base: String
        
        switch flag {
        case .debug:
            base = ""
        case .error:
            base = "Error: "
        case .warning:
            base = "Warning: "
        }
        
        print("\(base)\(message)")
    }
    
    func logDebug(_ message: Any) {
        log(message, flag: .debug)
    }
    
    func logError(_ message: Any) {
        log(message, flag: .error)
    }
    
    func logError(_ error: Swift.Error) {
        log(error.localizedDescription, flag: .error)
    }
    
    func logWarning(_ message: String) {
        log(message, flag: .warning)
    }
    
    func logResponse<T>(_ response: Response<T>) {
        switch response {
        case .success: logDebug("success")
        case .failure: logDebug("failure")
        }
    }
    
}
