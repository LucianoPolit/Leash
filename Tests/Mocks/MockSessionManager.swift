//
//  MockSessionManager.swift
//  Example
//
//  Created by Luciano Polit on 11/14/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Alamofire

class MockSessionManager: SessionManager {
    
    var requestCalled = false
    var requestParameterURLRequest: URLRequestConvertible?
    
    override func request(_ urlRequest: URLRequestConvertible) -> DataRequest {
        requestCalled = true
        requestParameterURLRequest = urlRequest
        return super.request(urlRequest)
    }
    
}
