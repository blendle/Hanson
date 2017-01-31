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
        let observable = TestObservable()
        let observationManager = ObservationManager()
        let observation = observationManager.observe(observable) { _ in }
        
        // Verify that one event handler has been added.
        XCTAssertEqual(observable.eventHandlers.count, 1)
        
        observationManager.unobserve(observation)
        
        // Verify that the event handler has been removed.
        XCTAssertTrue(observable.eventHandlers.isEmpty)
    }
    
    func testMultipleObservationsOnSameObservable() {
        let observable = TestObservable()
        let observationManager = ObservationManager()
        
        for _ in 0..<10 {
            observationManager.observe(observable) { _ in }
        }
        
        XCTAssertEqual(observable.eventHandlers.count, 10)
        
        observationManager.observations.forEach { observation in
            observationManager.unobserve(observation)
        }
        
        XCTAssertTrue(observable.eventHandlers.isEmpty)
    }
    
    func testUnobserveAll() {
        let observable = TestObservable()
        let observationManager = ObservationManager()
        
        // Add some sample observations.
        for _ in 0..<10 {
            observationManager.observe(observable) { _ in }
        }
        
        // Ensure all the observations have been added.
        XCTAssertEqual(observationManager.observations.count, 10)
        XCTAssertEqual(observable.eventHandlers.count, 10)
        
        // Verify that unobserving all removes all observations.
        observationManager.unobserveAll()
        XCTAssertTrue(observationManager.observations.isEmpty)
        XCTAssertTrue(observable.eventHandlers.isEmpty)
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
    
    func testBinding<O: Observable & Bindable, B: Bindable>(from observable: O, to bindable: B) where O.ValueType == String, O.ValueType == B.ValueType {
        let observationManager = ObservationManager()
        
        // After binding, the receiving bindable's value should be set to the observable's value.
        let observation = observationManager.bind(observable, to: bindable)
        XCTAssertEqual(observable.value, bindable.value)
        
        // After updating the observable's value, the receiving bindable's value should also be updated.
        observable.value = "Second Value"
        XCTAssertEqual(bindable.value, observable.value)
        
        // After updating the receiving bindable's value, the observable's value should be left the same.
        bindable.value = "Third Value"
        XCTAssertEqual(observable.value, "Second Value")
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
        
        // After binding, the custom property's setter should be invoked with the observable's initial value.
        observationManager.bind(fromProperty, to: toProperty)
        XCTAssertEqual(fromProperty.value, "Initial Value")
        XCTAssertEqual(fromProperty.value, toValue)
        
        // After updating the observable's value, the custom property's setter should be invoked.
        fromProperty.value = "Second Value"
        XCTAssertEqual(fromProperty.value, toValue)
        
        // After updating the custom property's value, the observable's value should be left the same.
        toProperty.value = "Third Value"
        XCTAssertEqual(fromProperty.value, "Second Value")
        XCTAssertEqual(toValue, "Third Value")
    }
    
}
