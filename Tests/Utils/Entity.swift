//
//  Entity.swift
//  Example
//
//  Created by Luciano Polit on 11/14/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
@testable import Leash

struct PrimitiveEntity: Codable, Equatable {
    
    let first: String
    let second: Int
    let third: Bool
    
    func toJSON() -> [String: Any] {
        return [
            "first": first,
            "second": second,
            "third": third
        ]
    }
    
}

func == (lhs: PrimitiveEntity, rhs: PrimitiveEntity) -> Bool {
    return lhs.first == rhs.first
        && lhs.second == rhs.second
        && lhs.third == rhs.third
}

struct DatedEntity: Codable, Equatable {
    let date: Date
}

func == (lhs: DatedEntity, rhs: DatedEntity) -> Bool {
    return lhs.date == rhs.date
}

struct QueryEntity: QueryEncodable {
    
    let first: String
    let second: Int
    let third: Bool
    
    func toQuery() -> [String: CustomStringConvertible] {
        return [
            "first": first,
            "second": second,
            "third": third
        ]
    }
    
}
