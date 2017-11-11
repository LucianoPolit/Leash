//
//  APIError.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation

struct APIError: Decodable {
    var message: String?
    var code: APIErrorCode
}

enum APIErrorCode: Int, Decodable {
    case invalidCredentials = 100
    case emailInUse = 110
}
