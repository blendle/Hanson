//
//  ObservableTests.swift
//  Hanson
//
//  Created by Joost van Dijk on 26/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import XCTest
@testable import Hanson

class ObservableTests: XCTestCase {
    
    func testPublishingEventWithoutEventHandlers() {
        let observable = TestObservable()
        observable.publish("Sample event")
    }
    
    func testPublishingMultipleEvents() {
        let observable = TestObservable()
        
        var latestEvent: String!
        observable.addEventHandler { event in
            latestEvent = event
        }
        
        // No event should have been published yet.
        XCTAssertNil(latestEvent)
        
        // When publishing an event, the event handler should be invoked with the published event.
        observable.publish("First event")
        XCTAssertEqual(latestEvent, "First event")
        
        observable.publish("Second event")
        XCTAssertEqual(latestEvent, "Second event")
    }
    
    func testPublishingMultipleEventsWithMultipleEventHandlers() {
        let observable = TestObservable()
        
        var numberOfFirstEventHandlerInvocations = 0
        let firstEventHandlerToken = observable.addEventHandler { _ in
            numberOfFirstEventHandlerInvocations += 1
        }
        
        var numberOfSecondEventHandlerInvocations = 0
        let secondEventHandlerToken = observable.addEventHandler { _ in
            numberOfSecondEventHandlerInvocations += 1
        }
        
        // When an event is published, both counter should increment.
        observable.publish("Sample event")
        XCTAssertEqual(numberOfFirstEventHandlerInvocations, 1)
        XCTAssertEqual(numberOfSecondEventHandlerInvocations, 1)
        
        // After removing an event handler, only one counter should increment when publishing an event.
        observable.removeEventHandler(with: firstEventHandlerToken)
        observable.publish("Sample event")
        XCTAssertEqual(numberOfFirstEventHandlerInvocations, 1)
        XCTAssertEqual(numberOfSecondEventHandlerInvocations, 2)
        
        // After removing the other event handler, neither of the counters should increment when publishing an event.
        observable.removeEventHandler(with: secondEventHandlerToken)
        XCTAssertEqual(numberOfFirstEventHandlerInvocations, 1)
        XCTAssertEqual(numberOfSecondEventHandlerInvocations, 2)
    }
    
    func testPublishingMultipleEventsOnMultipleQueuesWhileAddingEventHandlers() {
        let observable = TestObservable()
        
        var numberOfEvents = 0
        observable.addEventHandler { _ in
            numberOfEvents += 1
        }
        
        // Publish 100 events and add 100 event handlers on different queues.
        for i in 0..<100 {
            let publishExpectation = expectation(description: "Event \(i) published")
            
            let queue = DispatchQueue(label: "com.blendle.hanson.tests.observable.queue\(i)")
            queue.async {
                observable.publish("Event \(i)")
                observable.addEventHandler { _ in }
                
                publishExpectation.fulfill()
            }
        }
        
        // Wait until all events have been published and event handlers have been added.
        waitForExpectations(timeout: 10, handler: nil)
        
        // Verify that 100 events have been published.
        XCTAssertEqual(numberOfEvents, 100)
        
        // Verify that 100 event handlers have been added, on top of the original one.
        XCTAssertEqual(observable.eventHandlers.count, 101)
    }
    
    func testAddingAndRemovingEventHandlers() {
        let observable = TestObservable()
        
        // Initially, the observable shouldn't have any event handlers.
        XCTAssertTrue(observable.eventHandlers.isEmpty)
        
        // After adding the first event handler, the observable should have one event handler.
        let firstEventHandlerToken = observable.addEventHandler { _ in }
        XCTAssertEqual(observable.eventHandlers.count, 1)
        
        // After adding the second event handler, the observable should have two event handlers.
        let secondEventHandlerToken = observable.addEventHandler { _ in }
        XCTAssertEqual(observable.eventHandlers.count, 2)
        
        // After removing the first event handler, the observable should have one event handler.
        observable.removeEventHandler(with: firstEventHandlerToken)
        XCTAssertEqual(observable.eventHandlers.count, 1)
        
        // After removing the second and last event handler, the observable shouldn't have any event handlers.
        observable.removeEventHandler(with: secondEventHandlerToken)
        XCTAssertTrue(observable.eventHandlers.isEmpty)
    }
    
    func testAddingAndRemovingEventHandlersOnMultipleQueues() {
        let observable = TestObservable()
        
        // Add 100 event handlers on different queues.
        for i in 0..<100 {
            let eventHandlerExpectation = expectation(description: "Event handler \(i) registered")
            
            let queue = DispatchQueue(label: "com.blendle.hanson.tests.observable.queue\(i)")
            queue.async {
                observable.addEventHandler { _ in }
                
                eventHandlerExpectation.fulfill()
            }
        }
        
        // Wait until all event handlers have been added.
        waitForExpectations(timeout: 10, handler: nil)
        
        // Verify that all event handlers have been added.
        XCTAssertEqual(observable.eventHandlers.count, 100)
        
        // Remove the event handlers on different queues.
        for (eventHandlerToken, _) in observable.eventHandlers {
            let i = observable.eventHandlers.index(forKey: eventHandlerToken)
            let eventHandlerExpectation = expectation(description: "Event handler \(i) deregistered")
            
            let queue = DispatchQueue(label: "com.blendle.hanson.tests.observable.queue\(i)")
            queue.async {
                observable.removeEventHandler(with: eventHandlerToken)
                eventHandlerExpectation.fulfill()
            }
        }
        
        // Wait until all event handlers have been removed.
        waitForExpectations(timeout: 10, handler: nil)
        
        // Verify that all event handlers have been removed.
        XCTAssertTrue(observable.eventHandlers.isEmpty)
    }
    
}


