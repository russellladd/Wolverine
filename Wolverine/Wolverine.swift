//
//  Wolverine.swift
//  Wolverine
//
//  Created by Russell Ladd on 8/12/14.
//  Copyright (c) 2014 GRL5. All rights reserved.
//

import Foundation

public struct Credential {
    
    public let key: String
    public let secret: String
    
    let authorization: String
    
    public init(key: String, secret: String) {
        
        self.key = key
        self.secret = secret
        
        self.authorization = "Basic " + "\(key):\(secret)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!.base64EncodedStringWithOptions(nil)
    }
}

public enum ErrorCode: Int {
    
    public static let domain = "Wolverine"
    
    case InvalidJSON = 100
    
    internal var error: NSError {
        return NSError(domain: ErrorCode.domain, code: self.toRaw(), userInfo: nil)
    }
}

/*
public enum Result<T> {
    case Success(T)
    case Error(NSError)
}
*/

enum TokenResult {
    case Success(Token)
    case Error(NSError)
}

enum AnyObjectResult {
    case Success(AnyObject)
    case Error(NSError)
}

public enum PersonResult {
    case Success(Person)
    case Error(NSError)
}
