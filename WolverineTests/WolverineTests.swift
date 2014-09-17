//
//  WolverineTests.swift
//  WolverineTests
//
//  Created by Russell Ladd on 8/5/14.
//  Copyright (c) 2014 GRL5. All rights reserved.
//

import Wolverine
import XCTest

class WolverineTests: XCTestCase {
    
    class ServiceManagerTestDelegate: ServiceManagerDelegate {
        
        var serviceManagerDidChangeStatusHandler: (ServiceManager.Status -> ())?
        
        func serviceManager(serviceManager: ServiceManager, didChangeStatus status: ServiceManager.Status) {
            serviceManagerDidChangeStatusHandler?(status)
        }
    }

    func testServiceManager() {
        
        let serviceManager = ServiceManager(credential: Credential(key: "Wijw6wNYqffL0_ZnLOW9HemfEf8a", secret: "hjUuNq2CqsjchshuVsGnJs5Kenca"))
        
        let delegate = ServiceManagerTestDelegate()
        serviceManager.delegate = delegate
        
        let connectionExpectation = expectationWithDescription("Connect service manager")
        
        delegate.serviceManagerDidChangeStatusHandler = { status in
            
            connectionExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10.0) { error in
            
            switch serviceManager.status {
                
            case .Connected(let service):
                
                let personExpectation = self.expectationWithDescription("Ger person")
                
                service.getPersonWithUniqname("grladd") { result in
                    
                    personExpectation.fulfill()
                    
                    switch result {
                    case .Success(let person):
                        ()
                    case .Error(let error):
                        XCTFail("Service did not get person (Error: \(error))")
                    }
                }
                
                self.waitForExpectationsWithTimeout(10.0, nil)
                
            default:
                
                XCTFail("Service manager did not connect (Status: \(serviceManager.status))")
            }
        }
    }
}
