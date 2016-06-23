//
//  HTTPClient.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 26.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation
import RawConvertible

public enum HTTPClientQueryResult<T> {
    case Success(T)
    case Failure(ErrorType)
}

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
    
    public enum Error: ErrorType {
        case generic(String)
        case statusCode(Int, response: String)
        case contentTypeMismatch(expected: String, received: String)
    }
    
    private init() {
        fatalError("Not supported")
    }
    
    public init(sessionFactory: HTTPSessionFactory, requestTransformer: HTTPRequestTransformer = HTTPRequestTransformer()) {
        self.session = sessionFactory.sessionWithDelegate(self.sessionDelegate)
        self.requestTransformer = requestTransformer
    }

    // MARK: execute request
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

    // MARK: execute query
    public func execute<Q: HTTPQuery, T where T == Q.Result, T: ConvertibleFromRaw>(query: Q, completion: (HTTPClientQueryResult<T>) -> ()) {
        let request = query.request
        
        self.execute(request) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .Success(let response):
                do {
                    let responseBody = try strongSelf.bodyFromResponse(response, forRequest: request)
                    let result = try T(rawValue: responseBody)
                    completion(.Success(result))
                } catch (let error) {
                    completion(.Failure(error))
                }
            case .Failure(let error):
                completion(.Failure(error))
            }
        }
    }
    
    public func execute<Q: HTTPQuery, T where Q.Result: CollectionType, T == Q.Result.Generator.Element, T: ConvertibleFromRaw>(query: Q, completion: (HTTPClientQueryResult<[T]>) -> ()) {
        let request = query.request
        
        self.execute(request) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .Success(let response):
                do {
                    let responseBody = try strongSelf.bodyFromResponse(response, forRequest: request)
                    if let objectList = responseBody as? [AnyObject] {
                        let result: [T] = try objectList.map({ try T(rawValue: $0) })
                        completion(.Success(result))
                    } else {
                        completion(.Failure(Error.generic("Expected list of objects")))
                    }
                } catch (let error) {
                    completion(.Failure(error))
                }
            case .Failure(let error):
                completion(.Failure(error))
            }
        }
    }
}

extension HTTPClient {
    private func bodyFromResponse(response: Response, forRequest request: HTTPRequest) throws -> AnyObject {
        if response.statusCode / 100 != 2 {
            throw Error.statusCode(response.statusCode, response: response.debugDescription)
        }
        
        guard let contentType = response.headers.contentType else {
            return response.data
        }
        
        if let expectedContentType = request.headers.accept  where expectedContentType != contentType {
            throw Error.contentTypeMismatch(expected: expectedContentType.rawValue, received: contentType.rawValue)
        }
        
        switch contentType {
        case .json:
            return try NSJSONSerialization.JSONObjectWithData(response.data, options: NSJSONReadingOptions(rawValue: 0))
            
        case .html, .text:
            return String(data: response.data, encoding: NSUTF8StringEncoding) ?? response.data
        }
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
