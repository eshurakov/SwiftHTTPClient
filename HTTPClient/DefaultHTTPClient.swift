//
//  DefaultHTTPClient.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 26.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation
import RawConvertible

public final class DefaultHTTPClient: HTTPClient {    
    private let session: HTTPSession
    private let requestTransformer: HTTPRequestTransformer
    
    public let logger: HTTPClientLogger?

    public init(session: HTTPSession, requestTransformer: HTTPRequestTransformer = HTTPRequestTransformer(), logger: HTTPClientLogger? = nil) {
        self.session = session
        self.requestTransformer = requestTransformer
        self.logger = logger
    }
}

// MARK: - execute request
extension DefaultHTTPClient {
    public func execute(_ request: HTTPRequest, completion: (HTTPRequestResult) -> Void) {
        do {
            let urlRequest = try self.requestTransformer.transform(request)
            self.execute(urlRequest, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    public func execute(_ request: URLRequest, completion: (HTTPRequestResult) -> Void) {
        self.session.execute(request, completion: completion)
    }
}

// MARK: - execute query
extension DefaultHTTPClient {
    public func execute<Q: HTTPQuery, T where T == Q.Result, T: ConvertibleFromRaw>(_ query: Q, completion: (HTTPQueryResult<T>) -> ()) {
        let request = query.request
        
        self.execute(request) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let response):
                do {
                    let responseBody = try strongSelf.bodyFromResponse(response, forRequest: request)
                    let result = try T(rawValue: responseBody)
                    completion(.success(result, response))
                } catch (let error) {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func execute<Q: HTTPQuery, T where Q.Result: Collection, T == Q.Result.Iterator.Element, T: ConvertibleFromRaw>(_ query: Q, completion: (HTTPQueryResult<[T]>) -> ()) {
        let request = query.request
        
        self.execute(request) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let response):
                do {
                    let responseBody = try strongSelf.bodyFromResponse(response, forRequest: request)
                    if let objectList = responseBody as? [AnyObject] {
                        let result: [T] = try objectList.map({ try T(rawValue: $0) })
                        completion(.success(result, response))
                    } else {
                        completion(.failure(HTTPClientError.generic("Expected list of objects")))
                    }
                } catch (let error) {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension DefaultHTTPClient {
    private func bodyFromResponse(_ response: HTTPResponse, forRequest request: HTTPRequest) throws -> AnyObject {
        if response.statusCode / 100 != 2 {
            throw HTTPClientError.statusCode(response.statusCode, response: response.debugDescription)
        }
        
        guard let contentType = response.headers.contentType else {
            return response.data
        }
        
        if let expectedContentType = request.headers.accept, expectedContentType != contentType {
            throw HTTPClientError.contentTypeMismatch(expected: expectedContentType.rawValue, received: contentType.rawValue)
        }
        
        switch contentType {
        case .json:
            return try JSONSerialization.jsonObject(with: response.data as Data, options: JSONSerialization.ReadingOptions(rawValue: 0))
            
        case .html, .text:
            return String(data: response.data as Data, encoding: String.Encoding.utf8) ?? response.data
        }
    }
}
