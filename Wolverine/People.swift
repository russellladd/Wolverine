//
//  People.swift
//  Wolverine
//
//  Created by Russell Ladd on 8/5/14.
//  Copyright (c) 2014 GRL5. All rights reserved.
//

import Foundation

public struct Person {
    
    static func personWithJSONObject(jsonObject: AnyObject) -> PersonResult {
        
        if let dictionary = jsonObject as? NSDictionary {
            
            // Parse person
            
            return .Success(Person())
        }
        
        return .Error(ErrorCode.InvalidJSON.error)
    }
}

public extension Service {
    
    public func getPersonWithUniqname(uniqname: String, completionHandler: PersonResult -> ()) {
        
        get("Mcommunity/People/v1/people/\(uniqname)") { result in
            
            switch result {
                
            case .Success(let jsonObject):
                completionHandler(Person.personWithJSONObject(jsonObject))
                
            case .Error(let error):
                completionHandler(.Error(error))
            }
        }
    }
}
