//
//  Property.swift
//  Hanson
//
//  Created by Joost van Dijk on 24/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

/// The `Property` class represents a property that can be observed for changes to its `value` property.
/// When changing the property's value, the property will publish a `ValueChange` event with the old and new value.
public class Property<ValueType>: EventPublisher, Bindable {
    
    /// An alias for the event type that the property publishes.
    public typealias Event = ValueChange<ValueType>
    
    /// Initializes the property.
    ///
    /// - Parameter value: The property's initial value.
    public init(_ value: ValueType) {
        _value = value
    }
    
    // MARK: Value
    
    /// The value of the property. When setting this to a new value, the property will publish a `ValueChange` event with the old and new value.
    public var value: ValueType {
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
    
    /// Update the property's value without publishing an event.
    ///
    /// - Parameter value: The property's new value.
    public func silentlyUpdate(_ value: ValueType) {
        lock.lock()
        defer { lock.unlock() }
        
        _value = value
    }
    
    private var _value: ValueType
    
    // MARK: Event Handlers
    
    /// The event handlers to be invoked when the property updates its value.
    public var eventHandlers: [EventHandlerToken: EventHandler<ValueChange<ValueType>>] = [:]
    
    // MARK: Lock
    
    /// The lock used for operations related to event handlers and event publishing.
    public let lock = NSRecursiveLock("com.blendle.hanson.property")
    
}
