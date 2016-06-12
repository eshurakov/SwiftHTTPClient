//
//  Convertable.swift
//  APIClient
//
//  Created by Evgeny Shurakov on 13/05/16.
//  Copyright © 2016 BUX. All rights reserved.
//

import Foundation

public enum ConversionError: ErrorType {
    case invalidInput
    case generic(field: String)
}

public protocol ConvertableFromRaw {
    init(rawValue: AnyObject?) throws
}

public protocol ConvertableToRaw {
    func toRawValue() -> AnyObject
}

public protocol Convertable: ConvertableFromRaw, ConvertableToRaw {
    
}
