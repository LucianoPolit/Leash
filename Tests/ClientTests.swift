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
import OHHTTPStubs
@testable import Leash

class ClientTests: BaseTestCase { }

// MARK: - URLRequest

extension ClientTests {
    
    // MARK: - Method
    
    func testMethod() {
        let endpoint = Endpoint()
        assertNoErrorThrown {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertEqual(urlRequest.httpMethod, endpoint.method.rawValue)
        }
    }
    
    // MARK: - URL
    
    func testURLWithoutPortAndPath() {
        let endpoint = Endpoint(path: "some/another/123")
        manager = Manager.Builder()
            .scheme(ClientTests.scheme)
            .host(ClientTests.host)
            .build()
        assertNoErrorThrown {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertEqual(urlRequest.url?.absoluteString, "\(ClientTests.scheme)://\(ClientTests.host)/\(endpoint.path)")
        }
    }
    
    func testFullURL() {
        let endpoint = Endpoint(path: "some/another/123")
        assertNoErrorThrown {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertEqual(urlRequest.url?.absoluteString, "\(baseURL)\(endpoint.path)")
        }
    }
    
    // MARK: - Authorizator
    
    func testAuthorizatorWithoutAuthorization() {
        let endpoint = Endpoint()
        let authenticator = Authenticator()
        manager = builder
            .authenticator(authenticator)
            .build()
        assertNoErrorThrown {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertNil(urlRequest.value(forHTTPHeaderField: Authenticator.header))
        }
        
    }
    
    func testAuthorizatorWithAuthorization() {
        let endpoint = Endpoint()
        let authenticator = Authenticator()
        authenticator.authentication = "123"
        manager = builder
            .authenticator(authenticator)
            .build()
        assertNoErrorThrown {
            let urlRequest = try client.urlRequest(for: endpoint)
            let header = urlRequest.value(forHTTPHeaderField: Authenticator.header)
            XCTAssertNotNil(header)
            XCTAssertEqual(header, authenticator.authentication)
        }
    }
    
    // MARK: - Body
    
    func testEmptyBody() {
        let endpoint = Endpoint()
        assertNoErrorThrown {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertNil(urlRequest.httpBody)
        }
    }
    
    func testBodyWithEncodable() {
        let entity = PrimitiveEntity(first: "some", second: 10, third: true)
        let endpoint = Endpoint(method: .post, parameters: entity)
        assertNoErrorThrown {
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
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        manager = builder
            .jsonDateFormatter(formatter)
            .build()
        assertNoErrorThrown {
            let urlRequest = try client.urlRequest(for: endpoint)
            guard let body = urlRequest.httpBody else { return XCTFail() }
            let decoded = try manager.jsonDecoder.decode(DatedEntity.self, from: body)
            let dictionary = try JSONSerialization.jsonObject(with: body) as? [String : Any]
            XCTAssertEqual(decoded, entity)
            XCTAssertEqual(dictionary?["date"] as? String, "1970-01-01T00:01:40.0Z")
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
        assertNoErrorThrown {
            let urlRequest = try client.urlRequest(for: endpoint)
            guard let body = urlRequest.httpBody else { return XCTFail() }
            let dictionary = try JSONSerialization.jsonObject(with: body) as? [String : Any]
            XCTAssertEqual(dictionary?["date"] as? String, "1970-01-01T00:01:40Z")
        }
    }
    
    func testBodyWithDictionary() {
        let entity: [String : Any] = PrimitiveEntity(first: "some", second: 10, third: true).toJSON()
        let endpoint = Endpoint(method: .post, parameters: entity)
        assertNoErrorThrown {
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
        assertNoErrorThrown {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        }
    }
    
    func testContentTypeWithDictionary() {
        let entity = PrimitiveEntity(first: "some", second: 10, third: true).toJSON()
        let endpoint = Endpoint(method: .post, parameters: entity)
        assertNoErrorThrown {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        }
    }
    
    // MARK: - Query
    
    func testQueryWithQueryEncodable() {
        let entity = QueryEntity(first: "some", second: 10, third: true)
        let endpoint = Endpoint(method: .get, parameters: entity)
        assertNoErrorThrown {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertEqual(urlRequest.url?.absoluteString, "\(baseURL)?first=some&second=10&third=1")
        }
    }
    
    func testQueryWithDictionary() {
        let entity = QueryEntity(first: "some", second: 10, third: true).toQuery()
        let endpoint = Endpoint(method: .get, parameters: entity)
        assertNoErrorThrown {
            let urlRequest = try client.urlRequest(for: endpoint)
            XCTAssertEqual(urlRequest.url?.absoluteString, "\(baseURL)?first=some&second=10&third=1")
        }
    }
    
}

// MARK: - DataRequest

extension ClientTests {
    
    func testRequestCallsSessionManager() {
        let endpoint = Endpoint()
        let sessionManager = MockSessionManager()
        manager = builder
            .sessionManager(sessionManager)
            .build()
        assertNoErrorThrown {
            let dataRequest = try client.request(for: endpoint)
            XCTAssertTrue(sessionManager.requestCalled)
            XCTAssertTrue(dataRequest.request?.url?.absoluteString.contains(baseURL) ?? false)
        }
    }
    
    func testExecuteCallsResponse() {
        let endpoint = Endpoint(path: "response/123")
        let expectation = self.expectation(description: "Expected to succeed")
        let json = ["some" : "123"]
        stub(condition: isEndpoint(endpoint)) { _ in
            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }
        client.execute(endpoint: endpoint) { (response: Response<[String : String]>) in
            guard case .success(let result) = response else {
                XCTFail()
                return
            }
            XCTAssertEqual(result.value, ["some" : "123"])
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
}

// MARK: - Error

extension ClientTests {
    
    func testEncodingError() {
        let endpoint = Endpoint(method: .post, parameters: Data())
        let expectation = self.expectation(description: "Expected to fail")
        client.execute(endpoint: endpoint) { (response: Response<Data>) in
            guard case .failure(let error) = response, case Leash.Error.encoding(_) = error else {
                XCTFail()
                return
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
}

// MARK: - Utils

private extension ClientTests {
    
    func isEndpoint(_ endpoint: Endpoint) -> OHHTTPStubsTestBlock {
        return {
            return $0.url?.absoluteString == "\(self.baseURL)\(endpoint.path)"
                && $0.httpMethod == endpoint.method.rawValue
        }
    }
    
    var baseURL: String {
        return "\(ClientTests.scheme)://\(ClientTests.host):\(ClientTests.port)/\(ClientTests.path)/"
    }
    
}

private class MockSessionManager: SessionManager {
    
    var requestCalled = false
    var requestParameterURLRequest: URLRequestConvertible?
    
    override func request(_ urlRequest: URLRequestConvertible) -> DataRequest {
        requestCalled = true
        requestParameterURLRequest = urlRequest
        return super.request(urlRequest)
    }
    
}