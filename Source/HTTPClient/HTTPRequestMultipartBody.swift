//
//  HTTPRequestMultipartBody.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 17/02/2017.
//  Copyright © 2017 Evgeny Shurakov. All rights reserved.
//

import Foundation

public final class HTTPRequestMultipartBody: HTTPRequestBody {
    private let parameters: [String: String]
    private let attachments: [HTTPRequestAttachment]
    private let boundary = UUID().uuidString
    
    public init(parameters: [String: String], attachments: [HTTPRequestAttachment]) {
        self.parameters = parameters
        self.attachments = attachments
    }
    
    public func data() throws -> Data {
        var data = Data()
        
        data.append(self.data(for: self.parameters))
        data.append(self.data(for: self.attachments))
        
        data.append("--\(self.boundary)--\r\n".data(using: .utf8)!)
        
        return data
    }
    
    private func data(for parameters: [String: String]) -> Data {
        var result = ""
        for (key, value) in parameters {
            // TODO: escape
            result += "--\(self.boundary)\r\nContent-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)\r\n"
        }
        return result.data(using: .utf8)!
    }
    
    private func data(for attachments: [HTTPRequestAttachment]) -> Data {
        var data = Data()
        
        for attachment in attachments {
            data.append("--\(self.boundary)\r\n".data(using: .utf8)!)
            // TODO: escape
            data.append("Content-Disposition: form-data; name=\"\(attachment.name)\"; filename=\"\(attachment.name)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: \(attachment.contentType)\r\n\r\n".data(using: .utf8)!)
            data.append(attachment.data)
            data.append("\r\n".data(using: .utf8)!)
        }
        
        return data
    }
    
    public func headers() -> HTTPHeaders {
        let headers = HTTPHeaders()
        headers[HTTPHeaders.Key.ContentType] = "multipart/form-data; boundary=\(self.boundary)"
        return headers
    }
}
