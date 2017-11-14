//
//  Authenticator.swift
//  Example
//
//  Created by Luciano Polit on 11/14/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Leash

class Authenticator: Leash.Authenticator {
    static var header: String = "Authorization"
    var authentication: String?
}
