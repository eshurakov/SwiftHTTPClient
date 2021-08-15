//
//  HTTPRequestBody.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 31.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public protocol HTTPRequestBody {
    func data() throws -> Data
    func headers() -> HTTPHeaders
}
