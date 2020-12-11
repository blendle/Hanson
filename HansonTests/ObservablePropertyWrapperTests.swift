//
//  ObservablePropertyWrapperTests.swift
//  HansonTests
//
//  Created by Niklas Holloh on 26.07.19.
//  Copyright © 2019 Blendle. All rights reserved.
//

import XCTest
@testable import Hanson

class ObservablePropertyWrapperTests: XCTestCase {
    
    @Observable var value = "Hello World"
    
    func testObservingValue() {
        var lastEvent: ValueChange<String>!
        _value.addEventHandler { event in
            lastEvent = event
        }
        
        // Verify that changing the value publishes an event with the old and new value.
        value = "New Value"
        XCTAssertEqual(lastEvent.oldValue, "Hello World")
        XCTAssertEqual(lastEvent.newValue, "New Value")
        
        value = "Some Other Value"
        XCTAssertEqual(lastEvent.oldValue, "New Value")
        XCTAssertEqual(lastEvent.newValue, "Some Other Value")
    }
    
    func testSilentlyUpdatingValue() {
        var lastEvent: ValueChange<String>!
        _value.addEventHandler { event in
            lastEvent = event
        }
        
        // Verify that changing the value works via the silently update function.
        _value.silentlyUpdateValue(to: "New Value")
        XCTAssertEqual(value, "New Value")
        
        // Verify that no event has been published.
        XCTAssertNil(lastEvent)
        
    }
    
    func testUpdatingValueOnMultipleQueues() {
        var numberOfEvents = 0
        _value.addEventHandler { _ in
            numberOfEvents += 1
        }
        
        // Update the value 100 times on different queues.
        for i in 0..<100 {
            let valueExpectation = expectation(description: "Updated value")
            
            let queue = DispatchQueue(label: "com.blendle.hanson.tests.observable.queue\(i)")
            queue.async {
                self.value = "New Value"
                
                valueExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        // Verify that the value has been updated 100 times.
        XCTAssertEqual(numberOfEvents, 100)
    }
    
}
