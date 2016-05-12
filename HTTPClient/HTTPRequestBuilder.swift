//
//  HTTPRequestBuilder.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 26.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public final class HTTPRequestBuilder {
    public var baseURL: NSURL?
    public var cachePolicy = NSURLRequestCachePolicy.UseProtocolCachePolicy
    public var timeoutInterval: NSTimeInterval = 30
    public var headers = HTTPHeaders()
    
    public init(baseURL: NSURL? = nil) {
        self.baseURL = baseURL
    }
    
    func requestFromQuery(query: HTTPQuery) throws -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: URLFromQuery(query), cachePolicy: self.cachePolicy, timeoutInterval: self.timeoutInterval)
        
        let headers = HTTPHeaders(self.headers)
        headers.updateWithHeaders(query.headers)
        
        if let body = query.body {
            request.HTTPBody = try body.data()
            headers.updateWithHeaders(body.headers())
        }
        
        request.allHTTPHeaderFields = headers.rawValue
        request.HTTPMethod = query.method.rawValue
        
        return request
    }
    
    private func URLFromQuery(query: HTTPQuery) -> NSURL {
        if let baseURL = self.baseURL {
            return query.path.URLRelativeToURL(baseURL)
        } else {
            return query.path.URL()
        }
    }
}
