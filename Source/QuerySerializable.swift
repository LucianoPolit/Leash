//
//  QuerySerializable.swift
//  Pods-Example
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation

public protocol QuerySerializable {
    func toQuery() -> [String : CustomStringConvertible]
}
