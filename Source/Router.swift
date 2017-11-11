//
//  Router.swift
//  Pods-Example
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation
import Alamofire

public protocol Router {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Any? { get }
}
