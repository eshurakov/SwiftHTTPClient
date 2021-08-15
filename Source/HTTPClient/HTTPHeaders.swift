//
//  HTTPHeaders.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 27.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public final class HTTPHeaders {
    public struct Key: Hashable {
        public static let ContentType = "Content-Type"
        public static let Accept = "Accept"
        public static let Authorization = "Authorization"
                
        let value: String
        
        init(_ value: String) {
            self.value = value
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.value)
        }
    }
    
    public enum ContentType: String {
        case json = "application/json"
        case html = "text/html"
        case text = "text/plain"
    }
    
    public var accept: ContentType? {
        get {
            if let value = self[Key.Accept] {
                return ContentType.init(rawValue: value)
            }
            
            return nil
        }
        
        set {
            self[Key.Accept] = newValue?.rawValue
        }
    }
    
    public var contentType: ContentType? {
        get {
            if let value = self[Key.ContentType] {
                return ContentType.init(rawValue: value)
            }
            
            return nil
        }
        
        set {
            self[Key.ContentType] = newValue?.rawValue
        }
    }
    
    public var authorization: String? {
        get {
            return self[Key.Authorization]
        }
        
        set {
            self[Key.Authorization] = newValue
        }
    }
    
    public subscript(index: String) -> String? {
        get {
            return headers[Key(index)]
        }
        
        set {
            headers[Key(index)] = newValue
        }
    }
    
    public var rawValue: [String: String] {
        var result: [String: String] = [:]
        for (key, value) in self.headers {
            result[key.value] = value
        }
        return result
    }
    private var headers: [Key: String] = [:]
    
    public init() {
        
    }
    
    public init(_ headers: HTTPHeaders) {
        updateWithHeaders(headers)
    }
    
    public init(_ rawHeaders: [AnyHashable: Any]) {
        updateWithRawHeaders(rawHeaders)
    }
    
    func updateWithHeaders(_ headers: HTTPHeaders) {
        for (key, value) in headers.headers {
            self.headers[key] = value
        }
    }
    
    func updateWithRawHeaders(_ rawHeaders: [AnyHashable: Any]) {
        for (key, value) in rawHeaders {
            if let key = key as? String, let value = value as? String {
                headers[Key(key)] = value
            }
        }
    }
    
}

public func ==(lhs: HTTPHeaders.Key, rhs: HTTPHeaders.Key) -> Bool {
    return lhs.value.lowercased() == rhs.value.lowercased()
}
