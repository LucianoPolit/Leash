//
//  Error.swift
//  Pods-Example
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation

public enum Error: Swift.Error {
    case dataUnavailable
    case encoding(Swift.Error)
    case decoding(Swift.Error)
}
