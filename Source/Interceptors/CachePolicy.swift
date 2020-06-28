//
//  CachePolicy.swift
//
//  Copyright (c) 2017-2020 Luciano Polit <lucianopolit@gmail.com>
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

public protocol CachePolicyProtocol {
    func shouldCacheBeforeExecution() -> Bool
    func shouldCacheOnError(
        _ error: Swift.Error
    ) -> Bool
    func shouldSaveAfterSuccess() -> Bool
    func shouldFinishAfterCache() -> Bool
}

open class CachePolicy { }

extension CachePolicy {
    
    open class CacheAndRenew {
        
        public init() { }
        
    }
    
}

extension CachePolicy {
    
    open class CacheOnlyOnError {
        
        public init() { }
        
        open func isErrorCacheable(
            _ error: Swift.Error
        ) -> Bool {
            return true
        }
        
    }
    
}

extension CachePolicy.CacheAndRenew: CachePolicyProtocol {
    
    public func shouldCacheBeforeExecution() -> Bool {
        return true
    }
    
    public func shouldCacheOnError(
        _ error: Swift.Error
    ) -> Bool {
        return false
    }
    
    public func shouldSaveAfterSuccess() -> Bool {
        return true
    }
    
    public func shouldFinishAfterCache() -> Bool {
        return false
    }
    
}

extension CachePolicy.CacheOnlyOnError: CachePolicyProtocol {
    
    public func shouldCacheBeforeExecution() -> Bool {
        return false
    }
    
    public func shouldCacheOnError(
        _ error: Swift.Error
    ) -> Bool {
        return isErrorCacheable(error)
    }
    
    public func shouldSaveAfterSuccess() -> Bool {
        return true
    }
    
    public func shouldFinishAfterCache() -> Bool {
        return true
    }
    
}
