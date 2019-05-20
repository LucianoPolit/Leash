//
//  APIResponse.swift
//  Example
//
//  Created by Luciano Polit on 6/15/19.
//  Copyright © 2019 Luciano Polit. All rights reserved.
//

import Foundation

typealias APIResponse<T> = Result<T, Swift.Error>
typealias APICompletion<T> = (APIResponse<T>) -> ()
