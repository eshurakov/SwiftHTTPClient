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
        private let components: NSURLComponents
        private var queryItems: [NSURLQueryItem]?
        
        public init(_ path: String, _ pathParams: CVarArgType...) {
            self.components = NSURLComponents(string: String(format: path, arguments: pathParams))!
        }
        
        public func setQueryItem(name: String, value: String) {
            if self.queryItems == nil {
                self.queryItems = [NSURLQueryItem]()
            }
            
            self.queryItems!.append(NSURLQueryItem(name: name, value: value))
        }
        
        public func URL() -> NSURL {
            self.components.queryItems = self.queryItems
            return self.components.URL!
        }
        
        func URLRelativeToURL(baseURL: NSURL) -> NSURL {
            self.components.queryItems = self.queryItems
            return self.components.URLRelativeToURL(baseURL)!
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
    
}
