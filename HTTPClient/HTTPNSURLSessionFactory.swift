//
//  HTTPNSURLSessionFactory.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 27.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public final class HTTPNSURLSessionFactory: HTTPSessionFactory {
    private let configuration: NSURLSessionConfiguration
        
    public init(configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()) {
        self.configuration = configuration
    }
    
    public func sessionWithDelegate(delegate: NSURLSessionDelegate) -> NSURLSession {
        return NSURLSession(configuration: self.configuration, delegate: delegate, delegateQueue: NSOperationQueue.mainQueue())
    }
}
