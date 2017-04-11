//
//  Observable.swift
//  Hanson
//
//  Created by Joost van Dijk on 24/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

/// The `Observable` class represents a value that can be observed for changes.
/// When changing the observable's value, the observable will publish a `ValueChange` event with the old and new value.
public class Observable<Value>: EventPublisher, Bindable {
    
    /// An alias for the event type that the observable publishes.
    public typealias Event = ValueChange<Value>
    
    /// Initializes the observable.
    ///
    /// - Parameter value: The observable's initial value.
    public init(_ value: Value) {
        _value = value
    }
    
    // MARK: Value
    
    /// The value of the observable. When setting this to a new value, the observable will publish a `ValueChange` event with the old and new value.
    public var value: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            
            return _value
        }
        
        set {
            lock.lock()
            defer { lock.unlock() }
            
            let oldValue = _value
            
            _value = newValue
            
            let event = ValueChange(oldValue: oldValue, newValue: newValue)
            publish(event)
        }
    }
    
    /// Update the observable's value without publishing an event.
    ///
    /// - Parameter value: The observable's new value.
    public func silentlyUpdateValue(to value: Value) {
        lock.lock()
        defer { lock.unlock() }
        
        _value = value
    }
    
    private var _value: Value
    
    // MARK: Event Handlers
    
    /// The event handlers to be invoked when the observable updates its value.
    public var eventHandlers: [EventHandlerToken: EventHandler<ValueChange<Value>>] = [:]
    
    // MARK: Lock
    
    /// The lock used for operations related to event handlers and event publishing.
    public let lock = NSRecursiveLock("com.blendle.hanson.observable")
    
}
