//
//  HTTPDevLogger.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 11.06.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public final class HTTPDevLogger: HTTPLogger {
    private(set) public var logger: HTTPLoggerEngine
    var dataDescriptionLimit: Int = 1000
    
    public init(logger: HTTPLoggerEngine) {
        self.logger = logger
    }
    
    public func logRequest(for task: URLSessionTask) {
        if let headers = task.currentRequest?.allHTTPHeaderFields {
            self.logger.d("\(headers)")
        }
        
        if let body = task.currentRequest?.httpBody {
            self.logger.d(body.debugDescription(withLimit: self.dataDescriptionLimit))
        }
    }
    
    public func logResponse(_ response: HTTPResponse) {
        self.logger.d(response.data.debugDescription(withLimit: self.dataDescriptionLimit))
    }
}
