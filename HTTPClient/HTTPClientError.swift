//
//  HTTPClientError.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 24.06.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public enum HTTPClientError: Error {
    case generic(String)
    case statusCode(Int, response: String)
    case contentTypeMismatch(expected: String, received: String)
}
