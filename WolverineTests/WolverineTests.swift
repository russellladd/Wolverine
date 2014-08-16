//
//  WolverineTests.swift
//  WolverineTests
//
//  Created by Russell Ladd on 8/5/14.
//  Copyright (c) 2014 GRL5. All rights reserved.
//

import Wolverine
import XCTest

class WolverineTests: XCTestCase, ServiceManagerDelegate {
    
    func testServiceManager() {
        
        let serviceManager = ServiceManager(credential: Credential(key: "Wijw6wNYqffL0_ZnLOW9HemfEf8a", secret: "hjUuNq2CqsjchshuVsGnJs5Kenca"))
        
        
    }
    
    func serviceManager(serviceManager: ServiceManager, didChangeStatus status: ServiceManager.Status) {
        
        
    }
}
