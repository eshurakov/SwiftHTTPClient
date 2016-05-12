//
//  HTTPRequestBuilderTest.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 26.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import XCTest
@testable import HTTPClient

class HTTPRequestBuilderTest: XCTestCase {
    
    let requestBuilder = HTTPRequestBuilder(baseURL: NSURL(string: "https://test.com")!)
    
    override func setUp() {
        super.setUp()
        
    }
    
    func testPath() throws {
        let query = HTTPQuery(path: HTTPQueryPath("/test/path"))
        let request = try requestBuilder.requestFromQuery(query)
        
        XCTAssertEqual(request.URL!.absoluteString, "https://test.com/test/path")
        XCTAssertEqual(request.cachePolicy, requestBuilder.cachePolicy)
        XCTAssertEqual(request.timeoutInterval, requestBuilder.timeoutInterval)
    }
    
    func testHeaders() throws {
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer abcdefg"
        ]
        
        let query = HTTPQuery(path: HTTPQueryPath("/test/path"))
        for (name, value) in headers {
            query.headers[name] = value
        }
        
        let request = try requestBuilder.requestFromQuery(query)
        XCTAssertEqual(request.allHTTPHeaderFields!, headers)
    }
    
}
