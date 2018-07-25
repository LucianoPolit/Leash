//
//  APIFormatters.swift
//  Example
//
//  Created by Luciano Polit on 11/11/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation

/// Date formatter with the format that the API requires.
class APIDateFormatter: DateFormatter {
    
    override init() {
        super.init()
        dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
