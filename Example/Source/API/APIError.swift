//
//  APIError.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation

/// The error that can be found on the body of a response.
struct APIError: Decodable {
    var message: String?
    var code: APIErrorCode
}

/// The error code that can be found on an API error.
enum APIErrorCode: Int, Decodable {
    case invalidCredentials = 100
    case emailInUse = 110
}
