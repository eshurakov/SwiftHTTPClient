//
//  HTTPQuery.swift
//  APIClient
//
//  Created by Evgeny Shurakov on 13/05/16.
//  Copyright © 2016 BUX. All rights reserved.
//

import Foundation

public protocol HTTPQuery {
    associatedtype Result
    
    var request: HTTPRequest {get}
}
