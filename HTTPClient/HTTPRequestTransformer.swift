//
//  HTTPRequestTransformer.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 26.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public final class HTTPRequestTransformer {
    public var baseURL: NSURL?
    public var cachePolicy = NSURLRequestCachePolicy.UseProtocolCachePolicy
    public var timeoutInterval: NSTimeInterval = 30
    public var headers = HTTPHeaders()
    
    public init(baseURL: NSURL? = nil) {
        self.baseURL = baseURL
    }
    
    func transform(request: HTTPRequest) throws -> NSMutableURLRequest {
        let result = NSMutableURLRequest(URL: URLFromQuery(request), cachePolicy: self.cachePolicy, timeoutInterval: self.timeoutInterval)
        
        let headers = HTTPHeaders(self.headers)
        headers.updateWithHeaders(request.headers)
        
        if let body = request.body {
            result.HTTPBody = try body.data()
            headers.updateWithHeaders(body.headers())
        }
        
        result.allHTTPHeaderFields = headers.rawValue
        result.HTTPMethod = request.method.rawValue
        
        return result
    }
    
    private func URLFromQuery(request: HTTPRequest) -> NSURL {
        if let baseURL = self.baseURL {
            return request.path.URLRelativeToURL(baseURL)
        } else {
            return request.path.URL()
        }
    }
}
