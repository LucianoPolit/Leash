//
//  Endpoint.swift
//  Pods-Example
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation
import Alamofire

public protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Any? { get }
}
