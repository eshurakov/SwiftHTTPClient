//
//  HTTPRequest.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 26.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public final class HTTPRequest {
    public enum Method: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case PATCH = "PATCH"
        case DELETE = "DELETE"
    }
    
    public final class Path {
        private var components: URLComponents
        private var queryItems: [URLQueryItem]?
        
        // TODO: handle nil components
        // TODO: handle non-encoded paths
        public init(_ path: String, _ pathParams: CVarArg...) {
            self.components = URLComponents(string: String(format: path, arguments: pathParams))!
        }
        
        public func setQueryItem(_ name: String, value: String) {
            if self.queryItems == nil {
                self.queryItems = []
            }
            self.queryItems?.append(URLQueryItem(name: name, value: value))
        }
        
        public func URL() -> Foundation.URL {
            self.components.queryItems = self.queryItems
            return self.components.url!
        }
        
        func URLRelativeToURL(_ baseURL: Foundation.URL) -> Foundation.URL {
            self.components.queryItems = self.queryItems
            return self.components.url(relativeTo: baseURL)!
        }
        
    }
    
    public let path: Path
    public let method: Method
    
    public let headers = HTTPHeaders()
    public var body: HTTPRequestBody?
    
    public init(path: String, method: Method = .GET) {
        self.path = Path(path)
        self.method = method
    }
    
    public init(path: Path, method: Method = .GET) {
        self.path = path
        self.method = method
    }
}
