//
//  APIFormatters.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation

var APIDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
    return formatter
}()