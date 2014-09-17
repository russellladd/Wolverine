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
    public let aliases: [String]?
    public let displayName: String?
    public let email: String?
    public let title: String?
    public let uniqname: String?
    public let workAddress: String?
    public let workPhone: String?
    
    static func personWithJSONObject(jsonObject: AnyObject) -> Result<Person> {
        
        if let dictionary = jsonObject as? NSDictionary {
            
            func stringForProperty(property: String) -> String? {
                
                let object: AnyObject? = dictionary[property]
                
                if let array = object as? [String] {
                    return array.first
                }
                
                return object as? String
            }
            
            func stringArrayForProperty(property: String) -> [String]? {
                
                let object: AnyObject? = dictionary[property]
                
                if let string = object as? String {
                    return [string]
                }
                
                return object as? [String]
            }
            
            let affiliation: [String]? = stringArrayForProperty("affiliation")
            let aliases: [String]? = stringArrayForProperty("aliases")
            
            let displayName = stringForProperty("displayName")
            let email = stringForProperty("email")
            let title = stringForProperty("title")
            let uniqname = stringForProperty("uniqname")
            
            let workAddress = stringForProperty("workAddress")?.stringByReplacingOccurrencesOfString(" $ ", withString: "\n", options: nil, range: nil)
            let workPhone = stringForProperty("workPhone")?.stringByStrippingCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet);
            
            return .Success(Person(affiliation: affiliation, aliases: aliases, displayName: displayName, email: email, title: title, uniqname: uniqname, workAddress: workAddress, workPhone: workPhone))
        }
        
        return .Error(ErrorCode.InvalidJSON.error)
    }
    
    static func personArrayWithJSONObject(jsonObject: AnyObject) -> Result<[Result<Person>]> {
        
        if let dictionary = jsonObject as? NSDictionary {
            
            if let array = dictionary["person"] as? [AnyObject] {
                
                return .Success(array.map { personObject in
                    return Person.personWithJSONObject(personObject)
                })
            }
        }
        
        return .Error(ErrorCode.InvalidJSON.error)
    }
}

public extension Service {
    
    public func getPersonWithUniqname(uniqname: String, completionHandler: Result<Person> -> ()) -> NSURLSessionDataTask {
        
        return get("Mcommunity/People/v1/people/\(uniqname)") { result in
            
            switch result {
                
            case .Success(let jsonObject):
                completionHandler(Person.personWithJSONObject(jsonObject))
                
            case .Error(let error):
                completionHandler(.Error(error))
            }
        }
    }
    
    public func getPeopleForSearchString(searchString: String, completionHandler: Result<[Result<Person>]> -> ()) -> NSURLSessionDataTask {
        
        return get("Mcommunity/People/v1/people/compact/search/\(searchString)") { result in
            
            switch result {
                
            case .Success(let jsonObject):
                completionHandler(Person.personArrayWithJSONObject(jsonObject))
                
            case .Error(let error):
                completionHandler(.Error(error))
            }
        }
    }
}
