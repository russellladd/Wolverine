//
//  TokenTests.swift
//  Wolverine
//
//  Created by Russell Ladd on 8/5/14.
//  Copyright (c) 2014 GRL5. All rights reserved.
//

import Wolverine
import XCTest

class TokenTests: XCTestCase {
    
    var manager: TokenManager!
    
    override func setUp() {
        
        super.setUp()
        
        manager = TokenManager(consumerKey: "Wijw6wNYqffL0_ZnLOW9HemfEf8a", consumerSecret: "hjUuNq2CqsjchshuVsGnJs5Kenca")
    }
    
    override func tearDown() {
        
        manager = nil
        
        super.tearDown()
    }
    
    func testBase64Encode() {
        
        XCTAssertEqual(manager.combinedConsumerKeyAndSecret, "V2lqdzZ3TllxZmZMMF9abkxPVzlIZW1mRWY4YTpoalV1TnEyQ3FzamNoc2h1VnNHbkpzNUtlbmNh", "Consumer key and secret correctly base64 encoded")
    }
    
    func testFetchToken() {
        
        let expectation = expectationWithDescription("Fetch token")
        
        manager.fetchToken { error in
            
            expectation.fulfill()
            
            XCTAssert(self.manager.token != nil, "Token should not be nil")
        }
        
        waitForExpectationsWithTimeout(10.0, nil)
    }
}
