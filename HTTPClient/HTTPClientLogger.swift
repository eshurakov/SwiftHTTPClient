//
//  HTTPClientLogger.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 11.06.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation
import Log

public protocol HTTPClientLogger {
    var logger: Log {get}
    
    func logRequestDescription(for task: URLSessionTask)
    func logResponseDescription(for task: URLSessionTask, with data: Data?)
}

extension HTTPClientLogger {
    public func logTaskStart(_ task: URLSessionTask) {
        logTask(task, withAction: "start")
        self.logRequestDescription(for: task)
    }
    
    public func logTaskRedirect(_ task: URLSessionTask) {
        logTask(task, withAction: "redirect")
    }
    
    public func logTaskFailure(_ task: URLSessionTask, error: NSError) {
        // TOOD: log as a warning
        logTask(task, withAction: "failure")
        self.logger.w("\(error)")
    }
    
    public func logTaskSuccess(_ task: URLSessionTask, statusCode: Int, data: Data?) {
        logTask(task, withAction: "success [\(statusCode)]")
        self.logResponseDescription(for: task, with: data)
    }
    
    private func logTask(_ task: URLSessionTask, withAction action: String) {
        self.logger.d("\(action): \(self.descriptionForTask(task))")
    }
    
    private func descriptionForTask(_ task: URLSessionTask) -> String {
        let httpMethod = task.currentRequest?.httpMethod ?? "XXX"
        if let url = task.currentRequest?.url {
            return "\(httpMethod):\(url)"
        } else {
            return "\(httpMethod)"
        }
    }
}
