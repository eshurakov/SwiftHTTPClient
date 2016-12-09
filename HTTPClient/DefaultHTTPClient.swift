//
//  DefaultHTTPClient.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 26.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public final class DefaultHTTPClient: HTTPClient {
    fileprivate let session: HTTPSession
    fileprivate let requestTransformer: HTTPRequestTransformer
    
    public init(session: HTTPSession, requestTransformer: HTTPRequestTransformer) {
        self.session = session
        self.requestTransformer = requestTransformer
    }
}

// MARK: - execute request
extension DefaultHTTPClient {
    public func execute(_ request: HTTPRequest, completion: @escaping (HTTPRequestResult) -> Void) {
        do {
            let urlRequest = try self.requestTransformer.transform(request)
            
            self.session.execute(urlRequest) { (result) in
                switch result {
                case .success(let response):
                    completion(.success(response))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}
