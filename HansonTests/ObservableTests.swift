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
    
}


