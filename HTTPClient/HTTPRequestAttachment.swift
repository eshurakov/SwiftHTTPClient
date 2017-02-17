//
//  HTTPRequestAttachment.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 17/02/2017.
//  Copyright © 2017 Evgeny Shurakov. All rights reserved.
//

import Foundation

public final class HTTPRequestAttachment {
    public let name: String
    public let contentType: String
    public let data: Data
    
    public init(name: String, contentType: String, data: Data) {
        self.name = name
        self.contentType = contentType
        self.data = data
    }
}
