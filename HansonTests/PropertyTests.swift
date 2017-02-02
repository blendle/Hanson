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
    
    func testUpdatingValueOnMultipleQueues() {
        let property = Property("Initial Value")
        
        var numberOfEvents = 0
        property.addEventHandler { _ in
            numberOfEvents += 1
        }
        
        // Update the value 100 times on different queues.
        for i in 0..<100 {
            let valueExpectation = expectation(description: "Updated value")
            
            let queue = DispatchQueue(label: "com.blendle.hanson.tests.property.queue\(i)")
            queue.async {
                property.value = "New Value"
                
                valueExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        // Verify that the value has been updated 100 times.
        XCTAssertEqual(numberOfEvents, 100)
    }
    
}
