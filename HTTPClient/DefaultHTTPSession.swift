//
//  DefaultHTTPSession.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 30.07.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public class DefaultHTTPSession: NSObject, HTTPSession {
    fileprivate var taskContexts: [Int: TaskContext] = [:]
    
    fileprivate var session: Foundation.URLSession?
    private let sessionFactory: HTTPSessionFactory
    
    public var logger: HTTPClientLogger?
    
    private class TaskContext {
        lazy var data = Data()
        let completion: (HTTPRequestResult) -> Void
        
        init(completion: @escaping (HTTPRequestResult) -> Void) {
            self.completion = completion
        }
    }
    
    private override init() {
        fatalError("Not implemented")
    }
    
    public init(sessionFactory: HTTPSessionFactory) {
        self.sessionFactory = sessionFactory
        super.init()
    }
    
    public func execute(_ request: URLRequest, completion: @escaping (HTTPRequestResult) -> Void) {
        if self.session == nil {
            self.session = self.sessionFactory.session(withDelegate: self)
        }
        
        guard let session = self.session else {
            fatalError("Session is nil right after it was created")
        }
        
        let task = session.dataTask(with: request)
        
        self.logger?.logTaskStart(task)
        
        // TODO: call completion with a failure?
        assert(self.taskContexts[task.taskIdentifier] == nil)
        
        self.taskContexts[task.taskIdentifier] = TaskContext(completion: completion)
        task.resume()
    }
}

extension DefaultHTTPSession: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        self.session = nil
        self.logger?.logSessionFailure(error)
        
        let taskContexts = self.taskContexts
        self.taskContexts = [:]
        for (_, context) in taskContexts {
            context.completion(.failure(HTTPSessionError.becameInvalid(error)))
        }
    }
}

extension DefaultHTTPSession: URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        self.logger?.logTaskRedirect(task)
        completionHandler(request)
    }
        
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let context = self.taskContexts[task.taskIdentifier] else {
            return
        }
        
        self.taskContexts[task.taskIdentifier] = nil
        
        if let error = error {
            self.logger?.logTaskFailure(task, error: error)
            context.completion(.failure(error))
        } else {
            let headers = HTTPHeaders()
            let statusCode: Int
            if let httpResponse = task.response as? HTTPURLResponse {
                headers.updateWithRawHeaders(httpResponse.allHeaderFields)
                statusCode = httpResponse.statusCode
            } else {
                // TODO: fail?
                statusCode = 0
            }
            self.logger?.logTaskSuccess(task, statusCode: statusCode, data: context.data)
            
            let response = HTTPResponse(statusCode: statusCode, headers: headers, data: context.data)
            context.completion(.success(response))
        }
    }
}

extension DefaultHTTPSession: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let context = self.taskContexts[dataTask.taskIdentifier] else {
            return
        }
        
        context.data.append(data)
    }
}
