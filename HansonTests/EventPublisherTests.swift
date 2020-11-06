//
//  EventPublisherTests.swift
//  Hanson
//
//  Created by Joost van Dijk on 26/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import XCTest
@testable import Hanson

class EventPublisherTests: XCTestCase {
    
    func testPublishingEventWithoutEventHandlers() {
        let eventPublisher = TestEventPublisher()
        eventPublisher.publish("Sample event")
    }
    
    func testPublishingMultipleEvents() {
        let eventPublisher = TestEventPublisher()
        
        var latestEvent: String!
        eventPublisher.addEventHandler { event in
            latestEvent = event
        }
        
        // No event should have been published yet.
        XCTAssertNil(latestEvent)
        
        // When publishing an event, the event handler should be invoked with the published event.
        eventPublisher.publish("First event")
        XCTAssertEqual(latestEvent, "First event")
        
        eventPublisher.publish("Second event")
        XCTAssertEqual(latestEvent, "Second event")
    }
    
    func testPublishingMultipleEventsWithMultipleEventHandlers() {
        let eventPublisher = TestEventPublisher()
        
        var numberOfFirstEventHandlerInvocations = 0
        let firstEventHandlerToken = eventPublisher.addEventHandler { _ in
            numberOfFirstEventHandlerInvocations += 1
        }
        
        var numberOfSecondEventHandlerInvocations = 0
        let secondEventHandlerToken = eventPublisher.addEventHandler { _ in
            numberOfSecondEventHandlerInvocations += 1
        }
        
        // When an event is published, both counter should increment.
        eventPublisher.publish("Sample event")
        XCTAssertEqual(numberOfFirstEventHandlerInvocations, 1)
        XCTAssertEqual(numberOfSecondEventHandlerInvocations, 1)
        
        // After removing an event handler, only one counter should increment when publishing an event.
        eventPublisher.removeEventHandler(with: firstEventHandlerToken)
        eventPublisher.publish("Sample event")
        XCTAssertEqual(numberOfFirstEventHandlerInvocations, 1)
        XCTAssertEqual(numberOfSecondEventHandlerInvocations, 2)
        
        // After removing the other event handler, neither of the counters should increment when publishing an event.
        eventPublisher.removeEventHandler(with: secondEventHandlerToken)
        XCTAssertEqual(numberOfFirstEventHandlerInvocations, 1)
        XCTAssertEqual(numberOfSecondEventHandlerInvocations, 2)
    }
    
    func testPublishingMultipleEventsOnMultipleQueuesWhileAddingEventHandlers() {
        let eventPublisher = TestEventPublisher()
        
        var numberOfEvents = 0
        eventPublisher.addEventHandler { _ in
            numberOfEvents += 1
        }
        
        // Publish 100 events and add 100 event handlers on different queues.
        for i in 0..<100 {
            let publishExpectation = expectation(description: "Event \(i) published")
            
            let queue = DispatchQueue(label: "com.blendle.hanson.tests.event-publisher.queue\(i)")
            queue.async {
                eventPublisher.publish("Event \(i)")
                eventPublisher.addEventHandler { _ in }
                
                publishExpectation.fulfill()
            }
        }
        
        // Wait until all events have been published and event handlers have been added.
        waitForExpectations(timeout: 10, handler: nil)
        
        // Verify that 100 events have been published.
        XCTAssertEqual(numberOfEvents, 100)
        
        // Verify that 100 event handlers have been added, on top of the original one.
        XCTAssertEqual(eventPublisher.eventHandlers.count, 101)
    }
    
    func testAddingAndRemovingEventHandlers() {
        let eventPublisher = TestEventPublisher()
        
        // Initially, the event publisher shouldn't have any event handlers.
        XCTAssertTrue(eventPublisher.eventHandlers.isEmpty)
        
        // After adding the first event handler, the event publisher should have one event handler.
        let firstEventHandlerToken = eventPublisher.addEventHandler { _ in }
        XCTAssertEqual(eventPublisher.eventHandlers.count, 1)
        
        // After adding the second event handler, the event publisher should have two event handlers.
        let secondEventHandlerToken = eventPublisher.addEventHandler { _ in }
        XCTAssertEqual(eventPublisher.eventHandlers.count, 2)
        
        // After removing the first event handler, the event publisher should have one event handler.
        eventPublisher.removeEventHandler(with: firstEventHandlerToken)
        XCTAssertEqual(eventPublisher.eventHandlers.count, 1)
        
        // After removing the second and last event handler, the event publisher shouldn't have any event handlers.
        eventPublisher.removeEventHandler(with: secondEventHandlerToken)
        XCTAssertTrue(eventPublisher.eventHandlers.isEmpty)
    }
    
    func testAddingAndRemovingEventHandlersOnMultipleQueues() {
        let eventPublisher = TestEventPublisher()
        
        // Add 100 event handlers on different queues.
        for i in 0..<100 {
            let eventHandlerExpectation = expectation(description: "Event handler \(i) registered")
            
            let queue = DispatchQueue(label: "com.blendle.hanson.tests.event-publisher.queue\(i)")
            queue.async {
                eventPublisher.addEventHandler { _ in }
                
                eventHandlerExpectation.fulfill()
            }
        }
        
        // Wait until all event handlers have been added.
        waitForExpectations(timeout: 10, handler: nil)
        
        // Verify that all event handlers have been added.
        XCTAssertEqual(eventPublisher.eventHandlers.count, 100)
        
        // Remove the event handlers on different queues.
        for (i, element) in eventPublisher.eventHandlers.enumerated() {
            let eventHandlerToken = element.key
            let eventHandlerExpectation = expectation(description: "Event handler \(i) deregistered")
            
            let queue = DispatchQueue(label: "com.blendle.hanson.tests.event-publisher.queue\(i)")
            queue.async {
                eventPublisher.removeEventHandler(with: eventHandlerToken)
                eventHandlerExpectation.fulfill()
            }
        }
        
        // Wait until all event handlers have been removed.
        waitForExpectations(timeout: 10, handler: nil)
        
        // Verify that all event handlers have been removed.
        XCTAssertTrue(eventPublisher.eventHandlers.isEmpty)
    }

    func testPublishingEventWithCurrentThreadScheduler() {
        let eventPublisher = TestEventPublisher()

        // Add event handler with main thread scheduler
        let schedulerExpectation = expectation(description: "Event is sent on current thread")
        eventPublisher.addEventHandler({ _ in
            XCTAssertFalse(Thread.isMainThread)

            schedulerExpectation.fulfill()
        }, eventScheduler: CurrentThreadScheduler())

        // Publish event from background thread
        DispatchQueue.global(qos: .background).async {
            eventPublisher.publish("Sample event")
        }

        waitForExpectations(timeout: 10, handler: nil)
    }

    func testPublishingEventWithMainThreadScheduler() {
        let eventPublisher = TestEventPublisher()

        // Add event handler with main thread scheduler
        let schedulerExpectation = expectation(description: "Event is sent on main thread")
        eventPublisher.addEventHandler({ _ in
            XCTAssertTrue(Thread.isMainThread)

            schedulerExpectation.fulfill()
        }, eventScheduler: MainThreadScheduler())

        // Publish event from background thread
        DispatchQueue.global(qos: .background).async {
            eventPublisher.publish("Sample event")
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
    
}


