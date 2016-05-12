//
//  HTTPQuery.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 26.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public final class HTTPQuery {
    public enum Method: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    public let path: HTTPQueryPath
    public let method: Method
    
    public let headers = HTTPHeaders()
    public var body: HTTPQueryBody?
    
    public var retryCount = 2
    
    public init(path: String, method: Method = .GET) {
        self.path = HTTPQueryPath(path)
        self.method = method
    }
    
    public init(path: HTTPQueryPath, method: Method = .GET) {
        self.path = path
        self.method = method
    }
    
}
