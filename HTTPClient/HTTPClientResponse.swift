//
//  HTTPClientResponse.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 24.06.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public class HTTPClientResponse: CustomDebugStringConvertible {
    public let statusCode: Int
    public let headers: HTTPHeaders
    public let data: NSData
    
    init(statusCode: Int, headers: HTTPHeaders, data: NSData) {
        self.statusCode = statusCode
        self.headers = headers
        self.data = data
    }
    
    public var debugDescription: String {
        return String(data: self.data, encoding: NSUTF8StringEncoding) ?? ""
    }
}
