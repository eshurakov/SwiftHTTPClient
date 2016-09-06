//
//  HTTPSessionTest.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 14.08.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import XCTest
@testable import HTTPClient

class HTTPSessionTest: XCTestCase {
    fileprivate var session: HTTPSession!
    fileprivate var urlSessionFactory: MockHTTPSessionFactory!
    
    override func setUp() {
        super.setUp()
        self.urlSessionFactory = MockHTTPSessionFactory()
        self.session = DefaultHTTPSession(sessionFactory: self.urlSessionFactory)
    }
    
    func testSuccessfulExecution() {
        do {
            let url = URL(string: "https://google.com")!
            let headers: [String: String] = [
                "Content-type": "text/plain"
            ]
            
            let dataChunks = [
                "ho-ho-ho".data(using: .utf8)!
            ]
            
            self.testSuccessfulExecution(url: url, responseStatusCode: 200, responseHeaders: headers, dataChunks: dataChunks)
        }
        
        do {
            let url = URL(string: "http://google.com?s=http")!
            let headers: [String: String] = [
                "X-Powered-By": "Unit-Tests",
                "Expires": "Sat, 28 Nov 2009 05:36:25 GMT",
                "Etag": "pub1259380237;gz",
                "Cache-Control": "max-age=3600, public",
                "Content-Type": "text/html; charset=UTF-8",
                "Last-Modified": "Sat, 28 Nov 2009 03:50:37 GMT"
            ]
            
            let dataChunks = [
                "abc".data(using: .utf8)!,
                "qwe".data(using: .utf8)!
            ]
            
            self.testSuccessfulExecution(url: url, responseStatusCode: 400, responseHeaders: headers, dataChunks: dataChunks)
        }
    }
    
    func testSuccessfulExecution(url: URL, responseStatusCode: Int, responseHeaders: [String: String], dataChunks: [Data]?) {
        let expectation = self.expectation(description: "Execution expectation")
        let dataTask = self.successfulTask(withExpectation: expectation, url: url, responseStatusCode: responseStatusCode, responseHeaders: responseHeaders, dataChunks: dataChunks)
        
        self.urlSessionFactory.session.dataDelegate.urlSession!(self.urlSessionFactory.session, task: dataTask, didCompleteWithError: nil)
        
        self.waitForExpectations(timeout: 0.0, handler: nil)
    }
    
    func successfulTask(withExpectation expectation: XCTestExpectation, url: URL, responseStatusCode: Int, responseHeaders: [String: String], dataChunks: [Data]?) -> URLSessionDataTask {
        let request = URLRequest(url: url)
        let urlResponse = HTTPURLResponse(url: url, statusCode: responseStatusCode, httpVersion: "HTTP/1.1", headerFields: responseHeaders)
        
        self.session.execute(request) { (result) in
            expectation.fulfill()
            
            switch result {
            case .success(let response):
                XCTAssertEqual(response.statusCode, responseStatusCode)
                for (key, value) in responseHeaders {
                    XCTAssertEqual(response.headers[key], value)
                }
                if let dataChunks = dataChunks {
                    let expectedData = dataChunks.reduce(Data(), { return $0 + $1 })
                    XCTAssertEqual(response.data, expectedData)
                }
                
                break
                
            case .failure(let error):
                XCTAssertNil(error)
                break
            }
        }
        
        let urlSession = self.urlSessionFactory.session!
        let dataTask = urlSession.dataTasks.last!
        dataTask.mockResponse = urlResponse
        
        XCTAssertNotNil(dataTask)
        XCTAssertEqual(dataTask.originalRequest, request)
        
        if let dataChunks = dataChunks {
            for dataChunk in dataChunks {
                urlSession.dataDelegate.urlSession!(urlSession, dataTask: dataTask, didReceive: dataChunk)
            }
        }
        
        return dataTask
    }
    
    func testSuccessfulExecutionButNonHTTPResponse() {
        let expectation = self.expectation(description: "Execution expectation")
        
        let url = URL(string: "https://google.com")!
        let request = URLRequest(url: url)
        
        self.session.execute(request) { (result) in
            expectation.fulfill()
            
            switch result {
            case .success(let response):
                XCTAssertEqual(response.statusCode, 0)
                break
                
            case .failure(let error):
                XCTAssertNil(error)
                break
            }
        }
        
        let urlSession = self.urlSessionFactory.session!
        let dataTask = urlSession.dataTasks.last!
        
        XCTAssertNotNil(dataTask)
        XCTAssertEqual(dataTask.originalRequest, request)
        
        urlSession.dataDelegate.urlSession!(urlSession, task: dataTask, didCompleteWithError: nil)
        
        self.waitForExpectations(timeout: 0.0, handler: nil)
    }
}

extension HTTPSessionTest {
    func testFailedExecution() {
        let expectation = self.expectation(description: "Execution expectation")
        let url = URL(string: "https://google.com")!
        let expectedError = NSError(domain: "unit.test.error", code: 1042, userInfo: ["test2": "test1"])
        
        let dataTask = failTask(withExpectation: expectation, url: url, expectedError: expectedError)
        
        self.urlSessionFactory.session.dataDelegate.urlSession!(self.urlSessionFactory.session, task: dataTask, didCompleteWithError: expectedError)
        
        self.waitForExpectations(timeout: 0.0, handler: nil)
    }
    
    func failTask(withExpectation expectation: XCTestExpectation, url: URL, expectedError: NSError) -> URLSessionDataTask {
        let request = URLRequest(url: url)
        
        self.session.execute(request) { (result) in
            expectation.fulfill()
            
            switch result {
            case .success(let response):
                XCTAssertNil(response)
            
            case .failure(let error as HTTPSessionError):
                switch error {
                case .becameInvalid(let error as NSError):
                    XCTAssertEqual(expectedError, error)
                default:
                    XCTAssertTrue(false)
                }
                break
                
            case .failure(let error as NSError):
                XCTAssertEqual(expectedError, error)
                break
                
            default:
                XCTAssertTrue(false)
            }
        }
        
        let urlSession = self.urlSessionFactory.session!
        let dataTask = urlSession.dataTasks.last!
        
        XCTAssertNotNil(dataTask)
        XCTAssertEqual(dataTask.originalRequest, request)
        
        return dataTask
    }
}

extension HTTPSessionTest {
    func testSimultaneousRequests() {
        let url1 = URL(string: "https://google.com/1")!
        let headers1: [String: String] = [
            "task": "1"
        ]
        let expectation1 = self.expectation(description: "Execution expectation 1")
        let dataTask1 = self.successfulTask(withExpectation: expectation1, url: url1, responseStatusCode: 200, responseHeaders: headers1, dataChunks: nil)
        
        let url2 = URL(string: "https://google.com/2")!
        let headers2: [String: String] = [
            "task": "2"
        ]
        let expectation2 = self.expectation(description: "Execution expectation 2")
        let dataTask2 = self.successfulTask(withExpectation: expectation2, url: url2, responseStatusCode: 410, responseHeaders: headers2, dataChunks: nil)
        
        self.urlSessionFactory.session.dataDelegate.urlSession!(self.urlSessionFactory.session, task: dataTask2, didCompleteWithError: nil)
        self.urlSessionFactory.session.dataDelegate.urlSession!(self.urlSessionFactory.session, task: dataTask1, didCompleteWithError: nil)
        
        self.waitForExpectations(timeout: 0.0, handler: nil)
    }
}

extension HTTPSessionTest {
    func testInvalidatedSession() {
        let expectation1 = self.expectation(description: "Execution expectation 1")
        let expectation2 = self.expectation(description: "Execution expectation 2")
        let url = URL(string: "https://google.com")!
        let expectedError = NSError(domain: "unit.test.error", code: 1042, userInfo: ["test2": "test1"])
        _ = failTask(withExpectation: expectation1, url: url, expectedError: expectedError)
        _ = failTask(withExpectation: expectation2, url: url, expectedError: expectedError)
        
        self.urlSessionFactory.session.dataDelegate.urlSession!(self.urlSessionFactory.session, didBecomeInvalidWithError: expectedError)
        
        self.waitForExpectations(timeout: 0.0, handler: nil)
    }
    
    func testSessionIsRecreatedAfterInvalidation() {
        // TODO
    }
}
