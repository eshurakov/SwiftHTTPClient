//
//  HTTPClient.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 24.06.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation
import RawConvertible

public protocol HTTPClient {
    func execute(_ request: HTTPRequest, completion: (HTTPRequestResult) -> Void)
    func execute(_ request: URLRequest, completion: (HTTPRequestResult) -> Void)
    
    func execute<Q: HTTPQuery, T where T == Q.Result, T: ConvertibleFromRaw>(_ query: Q, completion: (HTTPQueryResult<T>) -> ())
    func execute<Q: HTTPQuery, T where Q.Result: Collection, T == Q.Result.Iterator.Element, T: ConvertibleFromRaw>(_ query: Q, completion: (HTTPQueryResult<[T]>) -> ())
}
