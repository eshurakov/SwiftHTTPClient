//
//  HTTPHeaders.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 27.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

// TODO: wrap key in an object, so that it would compare in a case-insensitive way 
public class HTTPHeaders {
    public struct Keys {
        public static let ContentType = "Content-Type"
        public static let Accept = "Accept"
        public static let Authorization = "Authorization"
        
        private init() {
            fatalError("Private init")
        }
    }
    
    public enum ContentType: String {
        case json = "application/json"
        case html = "text/html"
    }
    
    public var accept: ContentType? {
        get {
            if let value = self[Keys.Accept] {
                return ContentType.init(rawValue: value)
            }
            
            return nil
        }
        
        set {
            self[Keys.Accept] = newValue?.rawValue
        }
    }
    
    public var contentType: ContentType? {
        get {
            if let value = self[Keys.ContentType] {
                return ContentType.init(rawValue: value)
            }
            
            return nil
        }
        
        set {
            self[Keys.ContentType] = newValue?.rawValue
        }
    }
    
    public var authorization: String? {
        get {
            return self[Keys.Authorization]
        }
        
        set {
            self[Keys.Authorization] = newValue
        }
    }
    
    public subscript(index: String) -> String? {
        get {
            return headers[index.lowercaseString]
        }
        
        set {
            headers[index] = newValue
        }
    }
    
    public var rawValue: [String: String] {
        get {
            return self.headers
        }
    }
    private var headers: [String: String] = [:]
    
    public init() {
        
    }
    
    public init(_ headers: HTTPHeaders) {
        updateWithHeaders(headers)
    }
    
    func updateWithHeaders(headers: HTTPHeaders) {
        for (key, value) in headers.headers {
            self.headers[key] = value
        }
    }
    
    func updateWithRawHeaders(rawHeaders: [NSObject: AnyObject]) {
        for (key, value) in rawHeaders {
            if let key = key as? String, let value = value as? String {
                headers[key.lowercaseString] = value
            }
        }
    }
    
}
