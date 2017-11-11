//
//  Response.swift
//  Pods-Example
//
//  Created by Luciano Polit on 11/11/17.
//

import Foundation

public enum Response<T> {
    case success(T, extra: Any?)
    case failure(Swift.Error)
}
