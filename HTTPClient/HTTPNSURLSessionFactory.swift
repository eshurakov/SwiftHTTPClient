//
//  HTTPNSURLSessionFactory.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 27.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public class HTTPNSURLSessionFactory: HTTPSessionFactory {
    private let configuration: NSURLSessionConfiguration
    
    private init() {
        fatalError("Not implemented")
    }
    
    public init(configuration: NSURLSessionConfiguration) {
        self.configuration = configuration
    }
    
    public func sessionWithDelegate(delegate: NSURLSessionDelegate) -> NSURLSession {
        return NSURLSession(configuration: self.configuration, delegate: delegate, delegateQueue: NSOperationQueue.mainQueue())
    }
}
