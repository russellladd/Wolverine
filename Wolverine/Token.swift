//
//  Token.swift
//  Wolverine
//
//  Created by Russell Ladd on 8/5/14.
//  Copyright (c) 2014 GRL5. All rights reserved.
//

import Foundation

struct Token {
    
    let type: String
    let access: String
    let expirationDate: NSDate
    
    // TODO: Fix workaround once UM fixed their token response
    var authorization: String {
        return "Bearer \(access)"
        //return "\(type) \(access)"
    }
    
    var timeIntervalUntilExpiration: NSTimeInterval {
        return expirationDate.timeIntervalSinceNow
    }
    
    private init(type: String, access: String, expirationDate: NSDate) {
        
        self.type = type
        self.access = access
        self.expirationDate = expirationDate
    }
}

class TokenFetcher {
    
    let credential: Credential
    
    private let session: NSURLSession
    
    init(credential: Credential) {
        
        self.credential = credential
        
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        
        configuration.HTTPAdditionalHeaders = ["Authorization": credential.authorization]
        
        session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    deinit {
        session.invalidateAndCancel()
    }
    
    // Fetch a new token with a new token string. May be called at any time.
    func fetchToken(completionHandler: Result<Token> -> ()) {
        
        requestTokenWithHTTPBody("grant_type=client_credentials&scope=PRODUCTION", completionHandler: completionHandler)
    }
    
    // Refresh an existing token with a new expiration date. Will not have effect unless called after the current token expires.
    func refreshToken(token: Token, completionHandler: Result<Token> -> ()) {
        
        requestTokenWithHTTPBody("grant_type=refresh_token&refresh_token=\(token.access)&scope=PRODUCTION", completionHandler: completionHandler)
    }
    
    private func requestTokenWithHTTPBody(httpBody: String, completionHandler: Result<Token> -> ()) {
        
        let requestDate = NSDate()
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api-km.it.umich.edu/token"))
        request.HTTPMethod = "POST"
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            var jsonError: NSError?
            
            if error != nil {
                
                completionHandler(.Error(error))
                
            } else if let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? NSDictionary {
                
                let token_type = dictionary["token_type"] as? String
                let expires_in = dictionary["expires_in"] as? Int
                let access_token = dictionary["access_token"] as? String
                
                if (token_type != nil && expires_in != nil && access_token != nil) {
                    
                    let expirationDate = requestDate.dateByAddingTimeInterval(NSTimeInterval(expires_in!))
                    
                    let token = Token(type: token_type!, access: access_token!, expirationDate: expirationDate)
                    
                    completionHandler(.Success(token))
                    
                } else {
                    
                    completionHandler(.Error(ErrorCode.InvalidJSON.error))
                }
                
            } else {
                
                completionHandler(.Error(jsonError!))
            }
        }
        
        task.resume()
    }
}
