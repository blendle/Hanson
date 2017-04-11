//
//  DynamicObservableTests.swift
//  Hanson
//
//  Created by Joost van Dijk on 24/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import XCTest
@testable import Hanson

class DynamicObservableTests: XCTestCase {
    
    func testMirroringValue() {
        let testObject = TestObject(value: "Initial Value")
        let observable = testObject.dynamicObservable(keyPath: #keyPath(TestObject.value), type: String.self)
        
        // The observable should return the test object's initial value.
        XCTAssertEqual(observable.value, "Initial Value")
        
        // When setting a new value via the observable, the test object's value should be updated.
        observable.value = "Second Value"
        XCTAssertEqual(observable.value, "Second Value")
        XCTAssertEqual(observable.value, testObject.value)
        
        // When setting a new value via the test object, the observable's value should return the new value.
        testObject.value = "Third Value"
        XCTAssertEqual(testObject.value, "Third Value")
        XCTAssertEqual(testObject.value, observable.value)
    }
    
    func testObservingValue() {
        let testObject = TestObject(value: "Initial Value")
        let observable = testObject.dynamicObservable(keyPath: #keyPath(TestObject.value), type: String.self)
        
        var lastEvent: ValueChange<String>!
        observable.addEventHandler { event in
            lastEvent = event
        }
        
        // Verify that we haven't received any events yet.
        XCTAssertNil(lastEvent)
        
        // Verify that changing the value publishes an event with the old and new value.
        testObject.value = "Second Value"
        XCTAssertEqual(lastEvent.oldValue, "Initial Value")
        XCTAssertEqual(lastEvent.newValue, "Second Value")
        
        // Verify that changing the value via the observable publishes an event.
        observable.value = "Third Value"
        XCTAssertEqual(lastEvent.oldValue, "Second Value")
        XCTAssertEqual(lastEvent.newValue, "Third Value")
    }
    
    func testObservingWhenEventHandlersAreAdded() {
        let testObject = TestObject(value: "Initial Value")
        let observable = testObject.dynamicObservable(keyPath: #keyPath(TestObject.value), type: String.self)
        
        // Verify that the observer is not observing when no event handlers are added.
        XCTAssertFalse(observable.isObserving)
        
        // After adding an event handler, the observer should be observing.
        let firstEventHandlerToken = observable.addEventHandler { _ in }
        XCTAssertTrue(observable.isObserving)
        
        // After adding another event handler, the observer should still be observing.
        let secondEventHandlerToken = observable.addEventHandler { _ in }
        XCTAssertTrue(observable.isObserving)
        
        // After removing the first event handler, the observer should still be observing.
        observable.removeEventHandler(with: firstEventHandlerToken)
        XCTAssertTrue(observable.isObserving)
        
        // After removing the second and last event handler, the observer should stop observing.
        observable.removeEventHandler(with: secondEventHandlerToken)
        XCTAssertFalse(observable.isObserving)
    }
    
    func testObservingWhenEventHandlersAreAddedOnMultipleQueues() {
        let testObject = TestObject(value: "Initial Value")
        let observable = testObject.dynamicObservable(keyPath: #keyPath(TestObject.value), type: String.self)
        
        // Verify that the observer is not observing when no event handlers are added.
        XCTAssertFalse(observable.isObserving)
        
        // Add and remove 100 event handlers on different queues.
        for i in 0..<100 {
            let eventHandlerAddedExpectation = expectation(description: "Added event handler")
            let eventHandlerRemovedExpectation = expectation(description: "Removed event handler")
            
            let addEventHandlerQueue = DispatchQueue(label: "com.blendle.hanson.tests.dynamic-observable.add-event-handler-queue\(i)")
            addEventHandlerQueue.async {
                let eventHandlerToken = observable.addEventHandler { _ in }
                
                XCTAssertTrue(observable.isObserving)
                
                eventHandlerAddedExpectation.fulfill()
                
                let removeEventHandlerQueue = DispatchQueue(label: "com.blendle.hanson.tests.dynamic-roperty.remove-event-handler-queue\(i)")
                removeEventHandlerQueue.async {
                    observable.removeEventHandler(with: eventHandlerToken)
                    
                    eventHandlerRemovedExpectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertFalse(observable.isObserving)
    }
    
    func testRetainedTargetDuringObservation() {
        let testObject = TestObject(value: "Initial value")
        let observable = testObject.dynamicObservable(keyPath: #keyPath(TestObject.value), type: String.self)
        
        // Verify that the dynamic observable doesn't initially retain the target.
        XCTAssertNil(observable.retainedTarget)
        
        // After adding event handlers, the observable should retain its target.
        let firstEventHandlerToken = observable.addEventHandler { _ in }
        let secondEventHandlerToken = observable.addEventHandler { _ in }
        XCTAssertNotNil(observable.retainedTarget)
        
        // When removing the first event handler, the observable should still retain its target.
        observable.removeEventHandler(with: firstEventHandlerToken)
        XCTAssertNotNil(observable.retainedTarget)
        
        // When removing the second and last event handler, the observable should release its target.
        observable.removeEventHandler(with: secondEventHandlerToken)
        XCTAssertNil(observable.retainedTarget)
    }
    
    func testUnretainedTargetDuringObservation() {
        let testObject = TestObject(value: "Initial value")
        let observable = testObject.dynamicObservable(keyPath: #keyPath(TestObject.value), type: String.self, shouldRetainTarget: false) // Prevent retaining target.
        
        // Verify that the dynamic observable doesn't initially retain the target.
        XCTAssertNil(observable.retainedTarget)
        
        // After adding an event handler, the observable still should not retain its target.
        let eventHandlerToken = observable.addEventHandler { _ in }
        XCTAssertNil(observable.retainedTarget)
        
        // After removing the event handler, the observable still should not retain its target.
        observable.removeEventHandler(with: eventHandlerToken)
        XCTAssertNil(observable.retainedTarget)
    }
    
}
