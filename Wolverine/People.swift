//
//  People.swift
//  Wolverine
//
//  Created by Russell Ladd on 8/5/14.
//  Copyright (c) 2014 GRL5. All rights reserved.
//

import Foundation

public struct Person {
    
    public let affiliation: [String]?
    public let displayName: String?
    public let email: String?
    public let title: String?
    public let uniqname: String?
    public let workAddress: String? // convert " $ " to "\n"
    public let workPhone: String? // convert "###/" to "(###) "
    
    static func personWithJSONObject(jsonObject: AnyObject) -> PersonResult {
        
        if let dictionary = jsonObject as? NSDictionary {
            
            // Parse person
            
            return .Success(Person(affiliation: nil, displayName: nil, email: nil, title: nil, uniqname: nil, workAddress: nil, workPhone: nil))
        }
        
        return .Error(ErrorCode.InvalidJSON.error)
    }
}

public extension Service {
    
    public func getPersonWithUniqname(uniqname: String, completionHandler: PersonResult -> ()) -> NSURLSessionDataTask {
        
        return get("Mcommunity/People/v1/people/\(uniqname)") { result in
            
            switch result {
                
            case .Success(let jsonObject):
                completionHandler(.Success(Person.personWithJSONObject(jsonObject)))
                
            case .Error(let error):
                completionHandler(.Error(error))
            }
        }
    }
}
