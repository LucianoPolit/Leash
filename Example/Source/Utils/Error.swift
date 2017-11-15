//
//  Error.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation

/// The error of the project.
enum Error: Swift.Error {
    case server(APIError)
    case unauthorized
    case unknown
}
