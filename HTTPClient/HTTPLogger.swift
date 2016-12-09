//
//  HTTPLogger.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 11.06.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public protocol HTTPLoggerEngine {
    func e(_ message: @autoclosure () -> String)
    func w(_ message: @autoclosure () -> String)
    func i(_ message: @autoclosure () -> String)
    func d(_ message: @autoclosure () -> String)
}

public protocol HTTPLogger {
    var logger: HTTPLoggerEngine {get}
    
    func logRequest(for task: URLSessionTask)
    func logResponse(_ response: HTTPResponse)
}

extension HTTPLogger {
    public func logStart(of task: URLSessionTask) {
        logTask(task, withAction: "start")
        self.logRequest(for: task)
    }
    
    public func logRedirect(of task: URLSessionTask) {
        logTask(task, withAction: "redirect")
    }
    
    public func logFailure(of task: URLSessionTask, with error: Error) {
        logTask(task, withAction: "failure")
        self.logger.w("\(error)")
    }
    
    public func logSuccess(of task: URLSessionTask, with response: HTTPResponse) {
        logTask(task, withAction: "success [\(response.statusCode)]")
        self.logResponse(response)
    }
    
    public func logSessionFailure(_ error: Error?) {
        if let error = error {
            self.logger.e("Session became invalid with error: \(error)")
        } else {
            self.logger.e("Session became invalid")
        }
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
