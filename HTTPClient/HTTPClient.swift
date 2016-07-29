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
    func execute(request: HTTPRequest, completion: HTTPRequestResult -> Void)
    func execute(request: NSURLRequest, completion: HTTPRequestResult -> Void)
    
    func execute<Q: HTTPQuery, T where T == Q.Result, T: ConvertibleFromRaw>(query: Q, completion: (HTTPQueryResult<T>) -> ())
    func execute<Q: HTTPQuery, T where Q.Result: CollectionType, T == Q.Result.Generator.Element, T: ConvertibleFromRaw>(query: Q, completion: (HTTPQueryResult<[T]>) -> ())
}
