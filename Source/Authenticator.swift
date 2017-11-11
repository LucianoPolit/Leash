//
//  Authenticator.swift
//  Pods-Example
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation

public protocol Authenticator {
    static var header: String { get }
    var authentication: String? { get }
}
