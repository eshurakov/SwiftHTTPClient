//
//  MockHTTPSessionFactory.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 02.09.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation
@testable import HTTPClient

class MockHTTPSessionFactory: HTTPSessionFactory {
    var session: MockURLSession!
    
    func session(withDelegate delegate: URLSessionDataDelegate) -> URLSession {
        self.session = MockURLSession(delegate: delegate)
        return self.session
    }
}
