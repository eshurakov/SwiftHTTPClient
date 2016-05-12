//
//  HTTPSessionFactory.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 27.01.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public protocol HTTPSessionFactory {
    func sessionWithDelegate(delegate: NSURLSessionDelegate) -> NSURLSession
}
