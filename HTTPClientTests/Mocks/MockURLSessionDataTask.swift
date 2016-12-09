//
//  MockURLSessionDataTask.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 02.09.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

class MockURLSessionDataTask: URLSessionDataTask {
    static var globalTaskIdentifier: Int = 1
    
    var resumed: Bool = false
    
    var mockRequest: URLRequest?
    var mockResponse: URLResponse?
    
    init(request: URLRequest) {
        mockRequest = request
    }
    
    private var _taskIdentifier: Int = 0
    override var taskIdentifier: Int {
        if _taskIdentifier == 0 {
            _taskIdentifier = MockURLSessionDataTask.globalTaskIdentifier
            MockURLSessionDataTask.globalTaskIdentifier += 1
        }
        
        return _taskIdentifier
    }
    
    override var originalRequest: URLRequest? {
        return mockRequest
    }
    
    override var response: URLResponse? {
        return mockResponse
    }
    
    internal override func resume() {
        precondition(!self.resumed)
        self.resumed = true
    }
}
