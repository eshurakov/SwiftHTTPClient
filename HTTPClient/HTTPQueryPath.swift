//
//  HTTPQueryPath.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 26.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public final class HTTPQueryPath {
    private let components: NSURLComponents
    private var queryItems: [NSURLQueryItem]?
    
    public init(_ path: String, _ pathParams: CVarArgType...) {
        self.components = NSURLComponents(string: String(format: path, arguments: pathParams))!
    }
    
    public func setQueryItem(name: String, value: String) {
        if self.queryItems == nil {
            self.queryItems = [NSURLQueryItem]()
        }
        
        self.queryItems!.append(NSURLQueryItem(name: name, value: value))
    }
    
    public func URL() -> NSURL {
        self.components.queryItems = self.queryItems
        return self.components.URL!
    }
    
    func URLRelativeToURL(baseURL: NSURL) -> NSURL {
        self.components.queryItems = self.queryItems
        return self.components.URLRelativeToURL(baseURL)!
    }

}
