//
//  HTTPResponse.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 24.06.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public class HTTPResponse {
    public let statusCode: Int
    public let headers: HTTPHeaders
    public let data: Data
    
    init(with urlResponse: HTTPURLResponse, data: Data) {
        self.statusCode = urlResponse.statusCode
        self.headers = HTTPHeaders(urlResponse.allHeaderFields)
        self.data = data
    }
}

extension HTTPResponse: CustomDebugStringConvertible {
    public var debugDescription: String {
        return String(data: self.data, encoding: String.Encoding.utf8) ?? ""
    }
}
