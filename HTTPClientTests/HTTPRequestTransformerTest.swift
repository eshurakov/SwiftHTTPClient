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
    
    let requestTransformer = HTTPRequestTransformer(baseURL: URL(string: "https://test.com")!)
    
    override func setUp() {
        super.setUp()
    }
    
    func testPath() throws {
        let httpRequest = HTTPRequest(path: "/test/path")
        let request = try requestTransformer.transform(httpRequest)
        
        XCTAssertEqual(request.url!.absoluteString, "https://test.com/test/path")
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
        
        let request = try requestTransformer.transform(httpRequest)
        XCTAssertEqual(request.allHTTPHeaderFields!, headers)
    }
    
}
