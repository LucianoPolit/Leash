//
//  QueryEncodable.swift
//  Pods-Example
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation

public protocol QueryEncodable {
    func toQuery() -> [String : CustomStringConvertible]
}
