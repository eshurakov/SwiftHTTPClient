//
//  HTTPRequestProcessor.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 17/11/2016.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public protocol HTTPRequestProcessor {
    func process(_ request: HTTPRequest) throws -> HTTPRequest
}
