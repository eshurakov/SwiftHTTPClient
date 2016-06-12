//
//  HTTPRequestPreProcessor.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 24.03.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public protocol HTTPRequestPreProcessor {
    func process(request: HTTPRequest) throws -> HTTPRequest
}
