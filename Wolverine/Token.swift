//
//  Token.swift
//  Wolverine
//
//  Created by Russell Ladd on 8/5/14.
//  Copyright (c) 2014 GRL5. All rights reserved.
//

import Foundation

let baseURL = "https://api-gw.it.umich.edu"

public struct Token {
    
    public let type: String
    public let expirationDate: NSDate  //!
    public let tokenString: String
}

public class TokenManager {
    
    public let consumerKey: String
    public let consumerSecret: String
    
    public let combinedConsumerKeyAndSecret: String
    
    private let session: NSURLSession
    
    public init(consumerKey: String, consumerSecret: String) {
        
        // Keys
        
        self.consumerKey = consumerKey;
        self.consumerSecret = consumerSecret;
        
        let combinedData = (self.consumerKey + ":" + self.consumerSecret).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!;
        
        combinedConsumerKeyAndSecret = combinedData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.fromMask(0))
        
        // Session
        
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        
        configuration.HTTPAdditionalHeaders = ["Authorization": "Basic " + combinedConsumerKeyAndSecret]
        
        session = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    public private(set) var token: Token?
    
    public func fetchToken(completionHandler: (() -> ())?) {
        
        let url = "https://api-km.it.umich.edu/token"
        
        let request = NSMutableURLRequest(URL: NSURL(string: url))
        request.HTTPMethod = "POST"
        request.HTTPBody = "grant_type=client_credentials&scope=PRODUCTION".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTaskWithRequest(request) { [weak self] (data, response, error) in
            
            if error == nil {
                
                if let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.fromMask(0), error: nil) as? NSDictionary {
                    
                    let token_type = dictionary["token_type"] as? String
                    let expires_in = dictionary["expires_in"] as? Int
                    let access_token = dictionary["access_token"] as? String
                    
                    if (token_type != nil && expires_in != nil && access_token != nil) {
                        
                        let expirationDate = NSDate().dateByAddingTimeInterval(NSTimeInterval(expires_in!))
                        
                        self?.token = Token(type: token_type!, expirationDate: expirationDate, tokenString: access_token!)
                        
                        completionHandler?()
                    }
                    
                } else {
                    
                    let string = NSString(data: data, encoding: NSUTF8StringEncoding)
                    
                    println(string)
                }
            }
        }
        
        task.resume()
    }
}
