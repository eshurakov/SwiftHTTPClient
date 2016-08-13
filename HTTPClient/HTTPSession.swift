//
//  HTTPSession.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 30.07.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public protocol HTTPSession {
    func execute(_ request: URLRequest, completion: (HTTPRequestResult) -> Void)
}
