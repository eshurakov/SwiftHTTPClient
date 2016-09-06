//
//  HTTPRequestTransformer.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 26.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public final class HTTPRequestTransformer {
    public var baseURL: URL?
    public var cachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
    public var timeoutInterval: TimeInterval = 30
    public var headers = HTTPHeaders()
    
    public init(baseURL: URL? = nil) {
        self.baseURL = baseURL
    }
    
    func transform(_ request: HTTPRequest) throws -> URLRequest {
        var urlRequest = URLRequest(url: URLFromQuery(request), cachePolicy: self.cachePolicy, timeoutInterval: self.timeoutInterval)
        
        let headers = HTTPHeaders(self.headers)
        headers.updateWithHeaders(request.headers)
        
        if let body = request.body {
            urlRequest.httpBody = try body.data()
            headers.updateWithHeaders(body.headers())
        }
        
        urlRequest.allHTTPHeaderFields = headers.rawValue
        urlRequest.httpMethod = request.method.rawValue
        
        return urlRequest
    }
    
    private func URLFromQuery(_ request: HTTPRequest) -> URL {
        if let baseURL = self.baseURL {
            return request.path.URLRelativeToURL(baseURL)
        } else {
            return request.path.URL()
        }
    }
}
