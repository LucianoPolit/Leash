//
//  ManagerTests.swift
//  Example
//
//  Created by Luciano Polit on 11/27/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import XCTest
@testable import Leash

class ManagerTests: BaseTestCase { }

// MARK: - Builder

extension ManagerTests {
    
    // MARK: - URL
    
    func testURL() {
        guard let url = URL(string: baseURL) else {
            XCTFail()
            return
        }
        
        manager = Manager.Builder()
            .url(url)
            .build()
        
        XCTAssertEqual(url, manager.url)
    }
    
    func testURLString() {
        let url = baseURL
        
        manager = Manager.Builder()
            .url(url)
            .build()
        
        XCTAssertEqual(url, manager.url.absoluteString)
    }
    
    func testURLWithoutPortAndPath() {
        manager = Manager.Builder()
            .scheme(ManagerTests.scheme)
            .host(ManagerTests.host)
            .build()
        
        XCTAssertEqual("\(ManagerTests.scheme)://\(ManagerTests.host)", manager.url.absoluteString)
    }
    
    func testFullURL() {
        var url = baseURL
        url.removeLast()
        XCTAssertEqual(url, manager.url.absoluteString)
    }
    
    // MARK: - Interceptors
    
    func testExecutionInterceptor() {
        let interceptor = MockExecutionInterceptor()
        
        manager = Manager.Builder()
            .url(baseURL)
            .add(interceptor: interceptor)
            .build()
        
        XCTAssertEqual(manager.executionInterceptors.count, 1)
    }
    
    func testFailureInterceptor() {
        let interceptor = MockFailureInterceptor()
        
        manager = Manager.Builder()
            .url(baseURL)
            .add(interceptor: interceptor)
            .build()
        
        XCTAssertEqual(manager.failureInterceptors.count, 1)
    }
    
    func testSuccessInterceptor() {
        let interceptor = MockSuccessInterceptor()
        
        manager = Manager.Builder()
            .url(baseURL)
            .add(interceptor: interceptor)
            .build()
        
        XCTAssertEqual(manager.successInterceptors.count, 1)
    }
    
    func testCompletionInterceptor() {
        let interceptor = MockCompletionInterceptor()
        
        manager = Manager.Builder()
            .url(baseURL)
            .add(interceptor: interceptor)
            .build()
        
        XCTAssertEqual(manager.completionInterceptors.count, 1)
    }
    
    func testSerializationInterceptor() {
        let interceptor = MockSerializationInterceptor<Data>()
        
        manager = Manager.Builder()
            .url(baseURL)
            .add(interceptor: interceptor)
            .build()
        
        XCTAssertEqual(manager.serializationInterceptors.count, 1)
    }
    
    func testManyInterceptors() {
        manager = Manager.Builder()
            .url(baseURL)
            .interceptors([
                MockExecutionInterceptor(),
                MockFailureInterceptor(),
                MockSuccessInterceptor(),
                MockCompletionInterceptor(),
                MockSerializationInterceptor<Data>()
            ])
            .build()
        
        XCTAssertEqual(manager.executionInterceptors.count, 1)
        XCTAssertEqual(manager.failureInterceptors.count, 1)
        XCTAssertEqual(manager.successInterceptors.count, 1)
        XCTAssertEqual(manager.completionInterceptors.count, 1)
        XCTAssertEqual(manager.serializationInterceptors.count, 1)
    }
    
    // MARK: - Others
    
    func testAuthenticator() {
        let authenticator = Authenticator()
        
        manager = Manager.Builder()
            .url(baseURL)
            .authenticator(authenticator)
            .build()
        
        guard let managerAuthenticator = manager.authenticator as? Authenticator else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(authenticator === managerAuthenticator)
    }
    
    func testSessionManager() {
        let session = Session(startRequestsImmediately: false)
        
        manager = Manager.Builder()
            .url(baseURL)
            .session(session)
            .build()
        
        XCTAssertTrue(session === manager.session)
    }
    
    func testJSONEncoder() {
        manager = Manager.Builder()
            .url(baseURL)
            .jsonEncoder { encoder in
                encoder.dateEncodingStrategy = .iso8601
            }
            .build()
        
        guard case .iso8601 = manager.jsonEncoder.dateEncodingStrategy else {
            XCTFail()
            return
        }
    }
    
    func testJSONDecoder() {
        manager = Manager.Builder()
            .url(baseURL)
            .jsonDecoder { decoder in
                decoder.dateDecodingStrategy = .iso8601
            }
            .build()
        
        guard case .iso8601 = manager.jsonDecoder.dateDecodingStrategy else {
            XCTFail()
            return
        }
    }
    
    func testJSONDateFormatter() {
        let dateFormatter = DateFormatter()
        
        manager = Manager.Builder()
            .url(baseURL)
            .jsonDateFormatter(dateFormatter)
            .build()
        
        guard case .formatted(let encodingDateFormatter) = manager.jsonEncoder.dateEncodingStrategy else {
            XCTFail()
            return
        }
        XCTAssertTrue(dateFormatter === encodingDateFormatter)
        
        guard case .formatted(let decodingDateFormatter) = manager.jsonDecoder.dateDecodingStrategy else {
            XCTFail()
            return
        }
        XCTAssertTrue(dateFormatter === decodingDateFormatter)
    }
    
}
