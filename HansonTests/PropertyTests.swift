//
//  PropertyTests.swift
//  Hanson
//
//  Created by Joost van Dijk on 24/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import XCTest
@testable import Hanson

class PropertyTests: XCTestCase {
    
    func testObservingValue() {
        let property = Property("Hello World")
        
        var lastEvent: ValueChange<String>!
        property.addEventHandler { event in
            lastEvent = event
        }
        
        // Verify that changing the value publishes an event with the old and new value.
        property.value = "New Value"
        XCTAssertEqual(lastEvent.oldValue, "Hello World")
        XCTAssertEqual(lastEvent.newValue, "New Value")
        
        property.value = "Some Other Value"
        XCTAssertEqual(lastEvent.oldValue, "New Value")
        XCTAssertEqual(lastEvent.newValue, "Some Other Value")
    }
    
    func testSilentlyUpdatingValue() {
        let property = Property("Hello World")
        
        var lastEvent: ValueChange<String>!
        property.addEventHandler { event in
            lastEvent = event
        }
        
        // Verify that changing the value works via the silently update function.
        property.silentlyUpdate("New Value")
        XCTAssertEqual(property.value, "New Value")
        
        // Verify that no event has been published.
        XCTAssertNil(lastEvent)
        
    }
    
}
