//
//  Response.swift
//
//  Copyright (c) 2017 Luciano Polit <lucianopolit@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// Represents whether a request was successful or encountered an error.
public enum Response<T> {
    /// Represents a successful response.
    case success(value: T, extra: Any?)
    /// Represents a failed response.
    case failure(Swift.Error)
}

// MARK: - Utils

extension Response {
    
    public var isFailure: Bool {
        switch self {
        case .failure:
            return true
        case .success:
            return false
        }
    }
    
    public var isSuccess: Bool {
        switch self {
        case .failure:
            return false
        case .success:
            return true
        }
    }
    
}

extension Response {
    
    public var error: Swift.Error? {
        switch self {
        case .failure(let error):
            return error
        case .success:
            return nil
        }
    }
    
    public var value: T? {
        switch self {
        case .failure:
            return nil
        case .success(let value, _):
            return value
        }
    }
    
    public var extra: Any? {
        switch self {
        case .failure:
            return nil
        case .success(_, let extra):
            return extra
        }
    }
    
}
