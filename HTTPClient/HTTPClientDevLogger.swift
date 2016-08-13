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
    
    public func logRequestDescription(for task: URLSessionTask) {
        if let headers = task.currentRequest?.allHTTPHeaderFields {
            self.logger.d("\(headers)")
        }
        
        if let body = task.currentRequest?.httpBody {
            self.logger.d(self.dataDescription(body))
        }
    }
    
    public func logResponseDescription(for task: URLSessionTask, with data: Data?) {
        if let data = data {
            self.logger.d(self.dataDescription(data))
        }
    }
    
    public func dataDescription(_ data: Data) -> String {
        if data.count < 500 {
            return String(data: data, encoding: String.Encoding.utf8) ?? ""
        }
        
        return "Data [\(data.count) bytes]"
    }
}
