//
//  ObservationManagerTests.swift
//  Hanson
//
//  Created by Joost van Dijk on 23/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import XCTest
@testable import Hanson

class ObservationManagerTests: XCTestCase {
    
    func testObservingAndUnobserving() {
        let eventPublisher = TestEventPublisher()
        let observationManager = ObservationManager()
        let observation = observationManager.observe(eventPublisher) { _ in }
        
        // Verify that one event handler has been added.
        XCTAssertEqual(eventPublisher.eventHandlers.count, 1)
        
        observationManager.unobserve(observation)
        
        // Verify that the event handler has been removed.
        XCTAssertTrue(eventPublisher.eventHandlers.isEmpty)
    }
    
    func testMultipleObservationsOnSameEventPublisher() {
        let eventPublisher = TestEventPublisher()
        let observationManager = ObservationManager()
        
        for _ in 0..<10 {
            observationManager.observe(eventPublisher) { _ in }
        }
        
        XCTAssertEqual(eventPublisher.eventHandlers.count, 10)
        
        observationManager.observations.forEach { observation in
            observationManager.unobserve(observation)
        }
        
        XCTAssertTrue(eventPublisher.eventHandlers.isEmpty)
    }
    
    func testObservingAndUnobservingOnMultipleQueues() {
        let eventPublisher = TestEventPublisher()
        let observationManager = ObservationManager()
        
        // Add 100 observations on different queues.
        for i in 0..<100 {
            let observationExpectation = expectation(description: "Observation \(i) added")
            
            let queue = DispatchQueue(label: "com.blendle.hanson.tests.observation-manager.queue\(i)")
            queue.async {
                observationManager.observe(eventPublisher) { _ in }
                
                observationExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        // Verify that all observations have been added.
        XCTAssertEqual(observationManager.observations.count, 100)
        
        // Remove the observations on different queues.
        for observation in observationManager.observations {
            let i = observationManager.observations.index(of: observation)
            let observationExpectation = expectation(description: "Observation \(i) added")
            
            let queue = DispatchQueue(label: "com.blendle.hanson.tests.observation-manager.queue\(i)")
            queue.async {
                observationManager.unobserve(observation)
                
                observationExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        // Verify that all observations have been removed.
        XCTAssertTrue(observationManager.observations.isEmpty)
    }
    
    func testUnobserveAll() {
        let eventPublisher = TestEventPublisher()
        let observationManager = ObservationManager()
        
        // Add some sample observations.
        for _ in 0..<10 {
            observationManager.observe(eventPublisher) { _ in }
        }
        
        // Ensure all the observations have been added.
        XCTAssertEqual(observationManager.observations.count, 10)
        XCTAssertEqual(eventPublisher.eventHandlers.count, 10)
        
        // Verify that unobserving all removes all observations.
        observationManager.unobserveAll()
        XCTAssertTrue(observationManager.observations.isEmpty)
        XCTAssertTrue(eventPublisher.eventHandlers.isEmpty)
    }
    
    func testRetainingEventPublisherDuringObservation() {
        var eventPublisher: TestEventPublisher! = TestEventPublisher()
        weak var weakEventPublisher = eventPublisher
        
        let observationManager = ObservationManager()
        var observation: Observation! = observationManager.observe(eventPublisher) { _ in }
        
        // When removing our reference to the event publisher, the event publisher should still be retained by the observation manager.
        eventPublisher = nil
        XCTAssertNotNil(weakEventPublisher)
        
        // When removing the observation and our reference to the observation, the event publisher should be released.
        observationManager.unobserve(observation)
        observation = nil
        XCTAssertNil(weakEventPublisher)
    }
    
    // MARK: Bindings
    
    func testBindingWithProperties() {
        let fromProperty = Property("Initial Value")
        let toProperty = Property("")
        testBinding(from: fromProperty, to: toProperty)
    }
    
    func testBindingWithDynamicProperties() {
        let fromObject = TestObject(value: "Initial Value")
        let fromProperty = fromObject.dynamicProperty(keyPath: #keyPath(TestObject.value), type: String.self)
        
        let toObject = TestObject(value: "")
        let toProperty = toObject.dynamicProperty(keyPath: #keyPath(TestObject.value), type: String.self)
        
        testBinding(from: fromProperty, to: toProperty)
    }
    
    func testBindingFromPropertyToDynamicProperty() {
        let fromProperty = Property("Initial Value")
        
        let toObject = TestObject(value: "")
        let toProperty = toObject.dynamicProperty(keyPath: #keyPath(TestObject.value), type: String.self)
        
        testBinding(from: fromProperty, to: toProperty)
    }
    
    func testBindingFromDynamicPropertyToProperty() {
        let fromObject = TestObject(value: "Initial Value")
        let fromProperty = fromObject.dynamicProperty(keyPath: #keyPath(TestObject.value), type: String.self)
        
        let toObject = TestObject(value: "")
        let toProperty = toObject.dynamicProperty(keyPath: #keyPath(TestObject.value), type: String.self)
        
        testBinding(from: fromProperty, to: toProperty)
    }
    
    func testBinding<E: EventPublisher & Bindable, B: Bindable>(from eventPublisher: E, to bindable: B) where E.Value == String, E.Value == B.Value {
        let observationManager = ObservationManager()
        
        // After binding, the receiving bindable's value should be set to the event publisher's value.
        let observation = observationManager.bind(eventPublisher, to: bindable)
        XCTAssertEqual(eventPublisher.value, bindable.value)
        
        // After updating the event publisher's value, the receiving bindable's value should also be updated.
        eventPublisher.value = "Second Value"
        XCTAssertEqual(bindable.value, eventPublisher.value)
        
        // After updating the receiving bindable's value, the event publisher's value should be left the same.
        bindable.value = "Third Value"
        XCTAssertEqual(eventPublisher.value, "Second Value")
        XCTAssertEqual(bindable.value, "Third Value")
        
        observationManager.unobserve(observation)
    }
    
    // MARK: Binding with Custom Property
    
    func testBindingFromPropertyToCustomProperty() {
        let fromProperty = Property("Initial Value")
        
        var toValue = ""
        let toProperty = CustomProperty(target: self) { (_, value) in
            toValue = value
        }
        
        let observationManager = ObservationManager()
        
        // After binding, the custom property's setter should be invoked with the event publisher's initial value.
        observationManager.bind(fromProperty, to: toProperty)
        XCTAssertEqual(fromProperty.value, "Initial Value")
        XCTAssertEqual(fromProperty.value, toValue)
        
        // After updating the event publisher's value, the custom property's setter should be invoked.
        fromProperty.value = "Second Value"
        XCTAssertEqual(fromProperty.value, toValue)
        
        // After updating the custom property's value, the event publisher's value should be left the same.
        toProperty.value = "Third Value"
        XCTAssertEqual(fromProperty.value, "Second Value")
        XCTAssertEqual(toValue, "Third Value")
    }
    
}
