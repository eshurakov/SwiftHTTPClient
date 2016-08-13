//
//  HTTPNSURLSessionFactory.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 27.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public final class HTTPNSURLSessionFactory: HTTPSessionFactory {
    private let configuration: URLSessionConfiguration
        
    public init(configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.configuration = configuration
    }
    
    public func sessionWithDelegate(_ delegate: URLSessionDelegate) -> URLSession {
        return URLSession(configuration: self.configuration, delegate: delegate, delegateQueue: OperationQueue.main)
    }
}
