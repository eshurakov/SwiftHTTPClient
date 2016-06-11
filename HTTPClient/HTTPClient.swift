//
//  HTTPClient.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 26.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation
import Log

public class HTTPClient {
    private let session: NSURLSession
    private let sessionDelegate = HTTPSessionDelegate()
    private let requestBuilder = HTTPRequestBuilder()
    
    public var queryPreProcessor: HTTPQueryPreProcessor?
    public var logger: Log? {
        didSet {
            self.sessionDelegate.logger = self.logger
        }
    }
    
    public class Response {
        public let statusCode: Int
        public let headers: HTTPHeaders
        public let data: NSData
        
        init(statusCode: Int, headers: HTTPHeaders, data: NSData) {
            self.statusCode = statusCode
            self.headers = headers
            self.data = data
        }
        
        public func utf8DataString() -> String {
            if let result = NSString(data: self.data, encoding: NSUTF8StringEncoding) as? String {
                return result
            }
            
            return ""
        }
    }
    
    public enum RequestResult {
        case Success(Response)
        case Failure(ErrorType)
    }
    
    private init() {
        fatalError("Not supported")
    }
    
    public init(sessionFactory: HTTPSessionFactory) {
        self.session = sessionFactory.sessionWithDelegate(self.sessionDelegate)
    }
    
    public func execute(query: HTTPQuery, completion: RequestResult -> Void) {
        if let queryPreProcessor = self.queryPreProcessor {
            do {
                try queryPreProcessor.process(query)
            } catch {
                completion(.Failure(error))
                return
            }
        }
        
        do {
            let request = try self.requestBuilder.requestFromQuery(query)
            self.execute(request, completion: completion)
        } catch {
            completion(.Failure(error))
        }
    }
    
    public func execute(request: NSURLRequest, completion: RequestResult -> Void) {
        let task = self.session.dataTaskWithRequest(request)
        self.sessionDelegate.startTask(task, completion: completion)
    }
}

private class HTTPSessionDelegate: NSObject {
    private var contexts: [Int : Context] = [:]
    var logger: Log?
    
    class Context {
        lazy var data = NSMutableData()
        let completion: HTTPClient.RequestResult -> Void
        
        init(completion: HTTPClient.RequestResult -> Void) {
            self.completion = completion
        }
    }
    
    func startTask(task: NSURLSessionTask, completion: HTTPClient.RequestResult -> Void) {
        self.logger?.d("request: \(task.currentRequest?.HTTPMethod): \(task.currentRequest?.URL)")
        self.logger?.d("\(task.currentRequest?.allHTTPHeaderFields)")
        if let body = task.currentRequest?.HTTPBody {
            self.logger?.d(descriptionForData(body))
        }
        
        // TODO: call completion with a failure?
        assert(self.contexts[task.taskIdentifier] == nil)
        
        self.contexts[task.taskIdentifier] = Context(completion: completion)
        task.resume()
    }
    
    private func descriptionForData(data: NSData) -> String {
        if data.length < 500 {
            return String(data: data, encoding: NSUTF8StringEncoding) ?? ""
        }
        
        return "Data [\(data.length) bytes]"
    }
}

extension HTTPSessionDelegate: NSURLSessionDelegate {
    @objc private func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        // TODO
    }
}

extension HTTPSessionDelegate: NSURLSessionTaskDelegate {
    @objc private func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        self.logger?.d("redirect: \(request.HTTPMethod): \(request.URL)")
        completionHandler(request)
    }
    
    @objc private func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        guard let context = self.contexts[task.taskIdentifier] else {
            return
        }
        
        self.contexts[task.taskIdentifier] = nil
        
        if let error = error {
            self.logger?.w("fail: \(task.currentRequest?.HTTPMethod): \(task.currentRequest?.URL)")
            self.logger?.w("\(error)")
            
            context.completion(.Failure(error))
        } else {
            let headers = HTTPHeaders()
            let statusCode: Int
            if let httpResponse = task.response as? NSHTTPURLResponse {
                headers.updateWithRawHeaders(httpResponse.allHeaderFields)
                statusCode = httpResponse.statusCode
            } else {
                statusCode = 0
            }
            self.logger?.d("finish: [\(statusCode)] \(task.currentRequest?.HTTPMethod): \(task.currentRequest?.URL)")
            if context.data.length > 0 {
                self.logger?.d(descriptionForData(context.data))
            }
            
            let response = HTTPClient.Response(statusCode: statusCode, headers: headers, data: context.data)
            context.completion(.Success(response))
        }
    }
}

extension HTTPSessionDelegate: NSURLSessionDataDelegate {
    @objc private func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        guard let context = self.contexts[dataTask.taskIdentifier] else {
            return
        }
        
        context.data.appendData(data)
    }
}
