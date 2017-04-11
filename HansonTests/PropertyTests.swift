//
//  ObservableTests.swift
//  Hanson
//
//  Created by Joost van Dijk on 24/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import XCTest
@testable import Hanson

class ObservableTests: XCTestCase {
    
    func testObservingValue() {
        let observable = Observable("Hello World")
        
        var lastEvent: ValueChange<String>!
        observable.addEventHandler { event in
            lastEvent = event
        }
        
        // Verify that changing the value publishes an event with the old and new value.
        observable.value = "New Value"
        XCTAssertEqual(lastEvent.oldValue, "Hello World")
        XCTAssertEqual(lastEvent.newValue, "New Value")
        
        observable.value = "Some Other Value"
        XCTAssertEqual(lastEvent.oldValue, "New Value")
        XCTAssertEqual(lastEvent.newValue, "Some Other Value")
    }
    
    func testSilentlyUpdatingValue() {
        let observable = Observable("Hello World")
        
        var lastEvent: ValueChange<String>!
        observable.addEventHandler { event in
            lastEvent = event
        }
        
        // Verify that changing the value works via the silently update function.
        observable.silentlyUpdate("New Value")
        XCTAssertEqual(observable.value, "New Value")
        
        // Verify that no event has been published.
        XCTAssertNil(lastEvent)
        
    }
    
    func testUpdatingValueOnMultipleQueues() {
        let observable = Observable("Initial Value")
        
        var numberOfEvents = 0
        observable.addEventHandler { _ in
            numberOfEvents += 1
        }
        
        // Update the value 100 times on different queues.
        for i in 0..<100 {
            let valueExpectation = expectation(description: "Updated value")
            
            let queue = DispatchQueue(label: "com.blendle.hanson.tests.observable.queue\(i)")
            queue.async {
                observable.value = "New Value"
                
                valueExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        // Verify that the value has been updated 100 times.
        XCTAssertEqual(numberOfEvents, 100)
    }
    
}
