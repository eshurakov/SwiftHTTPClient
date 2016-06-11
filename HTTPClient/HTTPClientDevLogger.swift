//
//  HTTPClientDevLogger.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 11.06.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation
import Log

public final class HTTPClientDevLogger: HTTPClientLogger {
    private(set) public var logger: Log
    
    public init(logger: Log) {
        self.logger = logger
    }
    
    public func logRequestDescription(for task: NSURLSessionTask) {
        if let headers = task.currentRequest?.allHTTPHeaderFields {
            self.logger.d("\(headers)")
        }
        
        if let body = task.currentRequest?.HTTPBody {
            self.logger.d(self.dataDescription(body))
        }
    }
    
    public func logResponseDescription(for task: NSURLSessionTask, with data: NSData?) {
        if let data = data {
            self.logger.d(self.dataDescription(data))
        }
    }
    
    public func dataDescription(data: NSData) -> String {
        if data.length < 500 {
            return String(data: data, encoding: NSUTF8StringEncoding) ?? ""
        }
        
        return "Data [\(data.length) bytes]"
    }
}
