//
//  HTTPQueryJSONBody.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 31.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public final class HTTPQueryJSONBody: HTTPQueryBody {
    private let value: AnyObject
    
    public init(_ value: AnyObject) {
        self.value = value
    }
    
    public func data() throws -> NSData {
        return try NSJSONSerialization.dataWithJSONObject(self.value, options: NSJSONWritingOptions(rawValue: 0))
    }
    
    public func headers() -> HTTPHeaders {
        let headers = HTTPHeaders()
        headers.contentType = .json
        return headers
    }
}
