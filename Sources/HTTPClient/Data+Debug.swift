//
//  Data+Debug.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 09/12/2016.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

extension Data {
    func debugDescription(withLimit limit: Int) -> String {
        if self.count < limit {
            return String(data: self, encoding: String.Encoding.utf8) ?? ""
        } else {
            let data = self.subdata(in: 0..<limit)
            let description = String(data: data, encoding: String.Encoding.utf8) ?? ""
            return "\(description)... [\(self.count - limit) more bytes]"
        }
    }
}
