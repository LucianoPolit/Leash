//
//  BodyValidator.swift
//  Example
//
//  Created by Luciano Polit on 25/07/2018.
//  Copyright © 2018 Luciano Polit. All rights reserved.
//

import Foundation
import Leash

/// Interceptor responsible for validating the body.
/// In some cases, the body may contain an API error with extra information.
/// In case that an API error is found, the interception is completed with it.
class BodyValidator: Leash.BodyValidator<APIError> {
    
    init() {
        super.init(
            transform: { Error.server($0) }
        )
    }
    
}
