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
    
    func logRequestDescription(for task: NSURLSessionTask)
    func logResponseDescription(for task: NSURLSessionTask, with data: NSData?)
}

extension HTTPClientLogger {
    public func logTaskStart(task: NSURLSessionTask) {
        logTask(task, withAction: "start")
        self.logRequestDescription(for: task)
    }
    
    public func logTaskRedirect(task: NSURLSessionTask) {
        logTask(task, withAction: "redirect")
    }
    
    public func logTaskFailure(task: NSURLSessionTask, error: NSError) {
        // TOOD: log as a warning
        logTask(task, withAction: "failure")
        self.logger.w("\(error)")
    }
    
    public func logTaskSuccess(task: NSURLSessionTask, statusCode: Int, data: NSData?) {
        logTask(task, withAction: "success [\(statusCode)]")
        self.logResponseDescription(for: task, with: data)
    }
    
    private func logTask(task: NSURLSessionTask, withAction action: String) {
        self.logger.d("\(action): \(self.descriptionForTask(task))")
    }
    
    private func descriptionForTask(task: NSURLSessionTask) -> String {
        let httpMethod = task.currentRequest?.HTTPMethod ?? "XXX"
        let url = task.currentRequest?.URL ?? NSURL()
        return "\(httpMethod):\(url)"
    }
}
