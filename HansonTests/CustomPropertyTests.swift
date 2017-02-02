//
//  CustomPropertyTests.swift
//  Hanson
//
//  Created by Joost van Dijk on 02/02/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import XCTest
@testable import Hanson

class CustomPropertyTests: XCTestCase {
    
    func testSetter() {
        var lastValue: String!
        let customProperty = CustomProperty(target: self) { target, value in
            lastValue = value
        }
        
        // After initializing the custom property, nothing should have happened to our value yet.
        XCTAssertNil(lastValue)
        
        // After setting a new value, the closure should be invoked with the new value.
        customProperty.value = "New Value"
        XCTAssertEqual(lastValue, "New Value")
        
        customProperty.value = "Second Value"
        XCTAssertEqual(lastValue, "Second Value")
    }
    
}
