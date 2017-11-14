//
//  ClientTests.swift
//  Example
//
//  Created by Luciano Polit on 11/14/17.
//  Copyright © 2017 Luciano Polit. All rights reserved.
//

import Foundation
import Alamofire
import XCTest
@testable import Leash

class ClientTests: XCTestCase {
    
    static let scheme = "http"
    static let host = "localhost"
    static let port = 8080
    static let path = "api"
    
    var builder: Manager.Builder {
        return Manager.Builder()
            .scheme(ClientTests.scheme)
            .host(ClientTests.host)
            .port(ClientTests.port)
            .path(ClientTests.path)
    }
    var manager: Manager! {
        didSet {
            client = Client(manager: manager)
        }
    }
    var client: Client!
    
    override func setUp() {
        manager = builder.build()
    }
    
}

// MARK: - URLRequest

extension ClientTests {
    
    // MARK: - Method
    
    func testMethod() {
        let endpoint = Endpoint()
        assert {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertEqual(urlRequest.httpMethod, endpoint.method.rawValue)
        }
    }
    
    // MARK: - URL
    
    func testURLWithoutPortAndPath() {
        let endpoint = Endpoint(path: .somePath)
        manager = Manager.Builder()
            .scheme(ClientTests.scheme)
            .host(ClientTests.host)
            .build()
        assert {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertEqual(urlRequest.url?.absoluteString, "\(ClientTests.scheme)://\(ClientTests.host)/\(endpoint.path)")
        }
    }
    
    func testFullURL() {
        let endpoint = Endpoint(path: .somePath)
        assert {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertEqual(urlRequest.url?.absoluteString, "\(baseURL)\(endpoint.path)")
        }
    }
    
    // MARK: - Authorizator
    
    func testAuthorizatorWithoutAuthorization() {
        let endpoint = Endpoint()
        let authenticator = MockAuthenticator()
        manager = builder
            .authenticator(authenticator)
            .build()
        assert {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertNil(urlRequest.value(forHTTPHeaderField: MockAuthenticator.header))
        }
    }
    
    func testAuthorizatorWithAuthorization() {
        let endpoint = Endpoint()
        let authenticator = MockAuthenticator()
        authenticator.mockAuthentication = "123"
        manager = builder
            .authenticator(authenticator)
            .build()
        assert {
            let urlRequest = try client.urlRequest(for: endpoint)
            let header = urlRequest.value(forHTTPHeaderField: MockAuthenticator.header)
            XCTAssertNotNil(header)
            XCTAssertEqual(header, authenticator.authentication)
        }
    }
    
    // MARK: - Body
    
    func testEmptyBody() {
        let endpoint = Endpoint()
        assert {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertNil(urlRequest.httpBody)
        }
    }
    
    func testBodyWithEncodable() {
        let entity = PrimitiveEntity(first: "some", second: 10, third: true)
        let endpoint = Endpoint(method: .post, parameters: entity)
        assert {
            let urlRequest = try client.urlRequest(for: endpoint)
            guard let body = urlRequest.httpBody else { return XCTFail() }
            let decoded = try manager.jsonDecoder.decode(PrimitiveEntity.self, from: body)
            XCTAssertEqual(decoded, entity)
        }
    }
    
    func testBodyWithCustomDateFormatter() {
        let entity = DatedEntity(date: Date(timeIntervalSince1970: 100))
        let endpoint = Endpoint(method: .post, parameters: entity)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.S'Z'"
        manager = builder
            .jsonDateFormatter(formatter)
            .build()
        assert {
            let urlRequest = try client.urlRequest(for: endpoint)
            guard let body = urlRequest.httpBody else { return XCTFail() }
            let decoded = try manager.jsonDecoder.decode(DatedEntity.self, from: body)
            let dictionary = try JSONSerialization.jsonObject(with: body) as? [String : Any]
            XCTAssertEqual(decoded, entity)
            XCTAssertEqual(dictionary?["date"] as? String, "1970-01-01T01:01:40.0Z")
        }
    }
    
    func testBodyWithDifferentEncoderWithEncodable() {
        let entity = DatedEntity(date: Date(timeIntervalSince1970: 100))
        let endpoint = Endpoint(method: .post, parameters: entity)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.S'Z'"
        manager = builder
            .jsonEncoder { $0.dateEncodingStrategy = .iso8601 }
            .build()
        assert {
            let urlRequest = try client.urlRequest(for: endpoint)
            guard let body = urlRequest.httpBody else { return XCTFail() }
            let dictionary = try JSONSerialization.jsonObject(with: body) as? [String : Any]
            XCTAssertEqual(dictionary?["date"] as? String, "1970-01-01T00:01:40Z")
        }
    }
    
    func testBodyWithDictionary() {
        let entity: [String : Any] = PrimitiveEntity(first: "some", second: 10, third: true).toJSON()
        let endpoint = Endpoint(method: .post, parameters: entity)
        assert {
            let urlRequest = try client.urlRequest(for: endpoint)
            guard let body = urlRequest.httpBody else { return XCTFail() }
            let decoded = try manager.jsonDecoder.decode(PrimitiveEntity.self, from: body)
            XCTAssertTrue(NSDictionary(dictionary: decoded.toJSON()).isEqual(to: entity))
        }
    }
    
    // MARK: - Content Type
    
    func testContentTypeWithEncodable() {
        let entity = PrimitiveEntity(first: "some", second: 10, third: true)
        let endpoint = Endpoint(method: .post, parameters: entity)
        assert {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        }
    }
    
    func testContentTypeWithDictionary() {
        let entity = PrimitiveEntity(first: "some", second: 10, third: true).toJSON()
        let endpoint = Endpoint(method: .post, parameters: entity)
        assert {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        }
    }
    
    // MARK: - Query
    
    func testQueryWithQueryEncodable() {
        let entity = QueryEntity(first: "some", second: 10, third: true)
        let endpoint = Endpoint(method: .get, parameters: entity)
        assert {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertEqual(urlRequest.url?.absoluteString, "\(baseURL)?first=some&second=10&third=1")
        }
    }
    
    func testQueryWithDictionary() {
        let entity = QueryEntity(first: "some", second: 10, third: true).toQuery()
        let endpoint = Endpoint(method: .get, parameters: entity)
        assert {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertEqual(urlRequest.url?.absoluteString, "\(baseURL)?first=some&second=10&third=1")
        }
    }
    
}

// MARK: - Utils

private extension ClientTests {
    
    var baseURL: String {
        return "\(ClientTests.scheme)://\(ClientTests.host):\(ClientTests.port)/\(ClientTests.path)/"
    }
    
}

private extension String {
    static var empty = ""
    static var somePath = "some/another/123"
}

extension XCTestCase {
    
    func assert(_ closure: () throws -> ()) {
        do {
            try closure()
        } catch {
            XCTFail()
        }
    }
    
}
