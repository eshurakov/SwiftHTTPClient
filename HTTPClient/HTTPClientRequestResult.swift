//
//  HTTPClientRequestResult.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 24.06.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public enum HTTPClientRequestResult {
    case success(HTTPClientResponse)
    case failure(ErrorType)
}
