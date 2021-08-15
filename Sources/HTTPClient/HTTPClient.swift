//
//  HTTPClient.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 24.06.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    func execute(_ request: HTTPRequest, completion: @escaping (HTTPRequestResult) -> Void)
}
