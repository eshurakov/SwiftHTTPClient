//
//  HTTPRequestJSONBody.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 31.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public final class HTTPRequestJSONBody: HTTPRequestBody {
    private let value: AnyObject
    
    public init(_ value: AnyObject) {
        self.value = value
    }
    
    public func data() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self.value, options: [])
    }
    
    public func headers() -> HTTPHeaders {
        let headers = HTTPHeaders()
        headers.contentType = .json
        return headers
    }
}
