//
//  DynamicPropertyTests.swift
//  Hanson
//
//  Created by Joost van Dijk on 24/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import XCTest
@testable import Hanson

class DynamicPropertyTests: XCTestCase {
    
    func testMirroringValue() {
        let testObject = TestObject(value: "Initial Value")
        let property = testObject.dynamicProperty(keyPath: #keyPath(TestObject.value), type: String.self)
        
        // The property should return the test object's initial value.
        XCTAssertEqual(property.value, "Initial Value")
        
        // When setting a new value via the property, the test object's value should be updated.
        property.value = "Second Value"
        XCTAssertEqual(property.value, "Second Value")
        XCTAssertEqual(property.value, testObject.value)
        
        // When setting a new value via the test object, the property's value should return the new value.
        testObject.value = "Third Value"
        XCTAssertEqual(testObject.value, "Third Value")
        XCTAssertEqual(testObject.value, property.value)
    }
    
    func testObservingValue() {
        let testObject = TestObject(value: "Initial Value")
        let property = testObject.dynamicProperty(keyPath: #keyPath(TestObject.value), type: String.self)
        
        var lastEvent: ValueChange<String>!
        property.addEventHandler { event in
            lastEvent = event
        }
        
        // Verify that we haven't received any events yet.
        XCTAssertNil(lastEvent)
        
        // Verify that changing the value publishes an event with the old and new value.
        testObject.value = "Second Value"
        XCTAssertEqual(lastEvent.oldValue, "Initial Value")
        XCTAssertEqual(lastEvent.newValue, "Second Value")
        
        // Verify that changing the value via the property publishes an event.
        property.value = "Third Value"
        XCTAssertEqual(lastEvent.oldValue, "Second Value")
        XCTAssertEqual(lastEvent.newValue, "Third Value")
    }
    
    func testObservingWhenEventHandlersAreAdded() {
        let testObject = TestObject(value: "Initial Value")
        let property = testObject.dynamicProperty(keyPath: #keyPath(TestObject.value), type: String.self)
        
        // Verify that the observer is not observing when no event handlers are added.
        XCTAssertFalse(property.isObserving)
        
        // After adding an event handler, the observer should be observing.
        let firstEventHandlerToken = property.addEventHandler { _ in }
        XCTAssertTrue(property.isObserving)
        
        // After adding another event handler, the observer should still be observing.
        let secondEventHandlerToken = property.addEventHandler { _ in }
        XCTAssertTrue(property.isObserving)
        
        // After removing the first event handler, the observer should still be observing.
        property.removeEventHandler(with: firstEventHandlerToken)
        XCTAssertTrue(property.isObserving)
        
        // After removing the second and last event handler, the observer should stop observing.
        property.removeEventHandler(with: secondEventHandlerToken)
        XCTAssertFalse(property.isObserving)
    }
    
    func testRetainedTargetDuringObservation() {
        let testObject = TestObject(value: "Initial value")
        let property = testObject.dynamicProperty(keyPath: #keyPath(TestObject.value), type: String.self)
        
        // Verify that the dynamic property doesn't initially retain the target.
        XCTAssertNil(property.retainedTarget)
        
        // After adding event handlers, the property should retain its target.
        let firstEventHandlerToken = property.addEventHandler { _ in }
        let secondEventHandlerToken = property.addEventHandler { _ in }
        XCTAssertNotNil(property.retainedTarget)
        
        // When removing the first event handler, the property should still retain its target.
        property.removeEventHandler(with: firstEventHandlerToken)
        XCTAssertNotNil(property.retainedTarget)
        
        // When removing the second and last event handler, the property should release its target.
        property.removeEventHandler(with: secondEventHandlerToken)
        XCTAssertNil(property.retainedTarget)
    }
    
    func testUnretainedTargetDuringObservation() {
        let testObject = TestObject(value: "Initial value")
        let property = testObject.dynamicProperty(keyPath: #keyPath(TestObject.value), type: String.self, shouldRetainTarget: false) // Prevent retaining target.
        
        // Verify that the dynamic property doesn't initially retain the target.
        XCTAssertNil(property.retainedTarget)
        
        // After adding an event handler, the property still should not retain its target.
        let eventHandlerToken = property.addEventHandler { _ in }
        XCTAssertNil(property.retainedTarget)
        
        // After removing the event handler, the property still should not retain its target.
        property.removeEventHandler(with: eventHandlerToken)
        XCTAssertNil(property.retainedTarget)
    }
    
}
