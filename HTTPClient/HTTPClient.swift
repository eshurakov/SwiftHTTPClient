//
//  HTTPClient.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 26.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public class HTTPClient {
    private let session: NSURLSession
    private let sessionDelegate = HTTPSessionDelegate()
    private let requestTransformer: HTTPRequestTransformer
    
    public var requestPreProcessor: HTTPRequestPreProcessor?
    public var logger: HTTPClientLogger? {
        didSet {
            self.sessionDelegate.logger = self.logger
        }
    }
    
    public class Response: CustomDebugStringConvertible {
        public let statusCode: Int
        public let headers: HTTPHeaders
        public let data: NSData
        
        init(statusCode: Int, headers: HTTPHeaders, data: NSData) {
            self.statusCode = statusCode
            self.headers = headers
            self.data = data
        }
        
        public var debugDescription: String {
            return String(data: self.data, encoding: NSUTF8StringEncoding) ?? ""
        }
    }
    
    public enum RequestResult {
        case Success(Response)
        case Failure(ErrorType)
    }
    
    private init() {
        fatalError("Not supported")
    }
    
    public init(sessionFactory: HTTPSessionFactory, requestTransformer: HTTPRequestTransformer = HTTPRequestTransformer()) {
        self.session = sessionFactory.sessionWithDelegate(self.sessionDelegate)
        self.requestTransformer = requestTransformer
    }
    
    public func execute(request: HTTPRequest, completion: RequestResult -> Void) {
        var request = request
        if let requestPreProcessor = self.requestPreProcessor {
            do {
                request = try requestPreProcessor.process(request)
            } catch {
                completion(.Failure(error))
                return
            }
        }
        
        do {
            let urlRequest = try self.requestTransformer.transform(request)
            self.execute(urlRequest, completion: completion)
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
    private var taskContexts: [Int : Context] = [:]
    var logger: HTTPClientLogger?
    
    class Context {
        lazy var data = NSMutableData()
        let completion: HTTPClient.RequestResult -> Void
        
        init(completion: HTTPClient.RequestResult -> Void) {
            self.completion = completion
        }
    }
    
    func startTask(task: NSURLSessionTask, completion: HTTPClient.RequestResult -> Void) {
        self.logger?.logTaskStart(task)
                
        // TODO: call completion with a failure?
        assert(self.taskContexts[task.taskIdentifier] == nil)
        
        self.taskContexts[task.taskIdentifier] = Context(completion: completion)
        task.resume()
    }
}

extension HTTPSessionDelegate: NSURLSessionDelegate {
    @objc private func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        // TODO
    }
}

extension HTTPSessionDelegate: NSURLSessionTaskDelegate {
    @objc private func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        self.logger?.logTaskRedirect(task)
        completionHandler(request)
    }
    
    @objc private func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        guard let context = self.taskContexts[task.taskIdentifier] else {
            return
        }
        
        self.taskContexts[task.taskIdentifier] = nil
        
        if let error = error {
            self.logger?.logTaskFailure(task, error: error)
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
            self.logger?.logTaskSuccess(task, statusCode: statusCode, data: context.data)
            
            let response = HTTPClient.Response(statusCode: statusCode, headers: headers, data: context.data)
            context.completion(.Success(response))
        }
    }
}

extension HTTPSessionDelegate: NSURLSessionDataDelegate {
    @objc private func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        guard let context = self.taskContexts[dataTask.taskIdentifier] else {
            return
        }
        
        context.data.appendData(data)
    }
}
