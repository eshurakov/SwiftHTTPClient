//
//  HTTPRequestTransformerTest.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 26.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import XCTest
@testable import HTTPClient

class HTTPRequestTransformerTest: XCTestCase {
    
    let requestTransformer = HTTPRequestTransformerTest(baseURL: NSURL(string: "https://test.com")!)
    
    override func setUp() {
        super.setUp()
    }
    
    func testPath() throws {
        let httpRequest = HTTPRequest(path: "/test/path")
        let request = try requestTransformer.trasform(httpRequest)
        
        XCTAssertEqual(request.URL!.absoluteString, "https://test.com/test/path")
        XCTAssertEqual(request.cachePolicy, requestTransformer.cachePolicy)
        XCTAssertEqual(request.timeoutInterval, requestTransformer.timeoutInterval)
    }
    
    func testHeaders() throws {
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer abcdefg"
        ]
        
        let httpRequest = HTTPRequest(path: "/test/path")
        for (name, value) in headers {
            httpRequest.headers[name] = value
        }
        
        let request = try requestTransformer.trasform(query)
        XCTAssertEqual(request.allHTTPHeaderFields!, headers)
    }
    
}
