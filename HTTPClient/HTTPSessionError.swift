//
//  HTTPSessionError.swift
//  HTTPClient
//
//  Created by Evgeny Shurakov on 13.08.16.
//  Copyright © 2016 Evgeny Shurakov. All rights reserved.
//

import Foundation

public enum HTTPSessionError: Error {
    case becameInvalid(Error?)
}
