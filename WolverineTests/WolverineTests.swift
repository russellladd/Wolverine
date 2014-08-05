//
//  WolverineTests.swift
//  WolverineTests
//
//  Created by Russell Ladd on 8/5/14.
//  Copyright (c) 2014 GRL5. All rights reserved.
//

import Wolverine
import XCTest

class MAPITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testInit() {
        
        let manager = TokenManager(consumerKey: "Wijw6wNYqffL0_ZnLOW9HemfEf8a", consumerSecret: "hjUuNq2CqsjchshuVsGnJs5Kenca")
        
        XCTAssertEqual(manager.combinedConsumerKeyAndSecret, "V2lqdzZ3TllxZmZMMF9abkxPVzlIZW1mRWY4YTpoalV1TnEyQ3FzamNoc2h1VnNHbkpzNUtlbmNh", "Base64 encode works!")
    }
    
    func testFetchToken() {
        
        let expectation = expectationWithDescription("Fetch token")
        
        let manager = TokenManager(consumerKey: "Wijw6wNYqffL0_ZnLOW9HemfEf8a", consumerSecret: "hjUuNq2CqsjchshuVsGnJs5Kenca")
        
        manager.fetchToken {
            
            expectation.fulfill()
            
            XCTAssert(manager.token != nil, "Token should not be nil")
        }
        
        waitForExpectationsWithTimeout(10.0, nil)
    }
}
