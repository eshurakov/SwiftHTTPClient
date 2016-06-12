//
//  HTTPRequestPathTest.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 26.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import XCTest
import HTTPClient

class HTTPRequestPathTest: XCTestCase {
    
    func testPath() {
        let path = HTTPRequest.Path("test/something")
        
        XCTAssertEqual(path.URL().absoluteString, "test/something")
    }
    
    func testParams() {
        do {
            let path = HTTPRequest.Path("test/something/%@/more/%d", "param", 42)
            XCTAssertEqual(path.URL().absoluteString, "test/something/param/more/42")
        }
    }
    
    func testQueryItems() {
        do {
            let path = HTTPRequest.Path("test/something/%@/more/%d", "param", 42)
            path.setQueryItem("a", value: "b")
            
            XCTAssertEqual(path.URL().absoluteString, "test/something/param/more/42?a=b")
        }
        
        do {
            let path = HTTPRequest.Path("test/something/%@/more/%d", "param", 42)
            path.setQueryItem("a", value: "b")
            path.setQueryItem("a b", value: "b=20")
            
            XCTAssertEqual(path.URL().absoluteString, "test/something/param/more/42?a=b&a%20b=b%3D20")
        }
    }
    
}
