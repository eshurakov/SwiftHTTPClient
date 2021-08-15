//
//  MockURLSession.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 02.09.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

class MockURLSession: URLSession {
    var dataDelegate: URLSessionDataDelegate
    var dataTasks: [MockURLSessionDataTask] = []
    
    init(delegate: URLSessionDataDelegate) {
        self.dataDelegate = delegate
        super.init()
    }
    
    internal override func dataTask(with url: URL) -> URLSessionDataTask {
        fatalError("Not supported")
    }
    
    internal override func dataTask(with request: URLRequest) -> URLSessionDataTask {
        let task = MockURLSessionDataTask(request: request)
        dataTasks.append(task)
        return task
    }
}
