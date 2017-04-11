//
//  DynamicProperty.swift
//  Hanson
//
//  Created by Joost van Dijk on 24/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

/// The `DynamicProperty` class represents a dynamic property that can be observed for changes using KVO.
/// When a change is detected with KVO, the property will publish a `ValueChange` event with the old and new value.
public class DynamicProperty<ValueType>: NSObject, EventPublisher, Bindable {
    
    /// An alias for the event type that the dynamic property publishes.
    public typealias EventType = ValueChange<ValueType>
    
    /// The target instance whose property should be observed.
    public unowned let target: NSObject
    
    /// The key path to the property that should be observed.
    public let keyPath: String
    
    /// A boolean value indicating whether the target should be retained while the dynamic property is being observed.
    public let shouldRetainTarget: Bool
    
    /// Initializes the dynamic property.
    ///
    /// - Parameters:
    ///   - target: The target instance whose property should be observed.
    ///   - keyPath: The key path to the property that should be observed.
    ///   - type: The type of property that is being observed.
    ///   - shouldRetainTarget: Whether or not the target should be retained while the dynamic property is being observed. Defaults to true.
    public init(target: NSObject, keyPath: String, type: ValueType.Type, shouldRetainTarget: Bool = true) {
        self.target = target
        self.keyPath = keyPath
        self.shouldRetainTarget = shouldRetainTarget
    }
    
    deinit {
        stopObservation()
    }
    
    // MARK: Value
    
    /// The value of the property. This value is being mirrored to the target instance via KVC.
    public var value: ValueType {
        get {
            return target.value(forKeyPath: keyPath) as! ValueType
        }
        
        set {
            target.setValue(newValue, forKeyPath: keyPath)
        }
    }
    
    // MARK: Key Value Observation
    
    internal var retainedTarget: NSObject?
    
    internal var isObserving = false
    
    private func startObservation() {
        guard isObserving == false else {
            return
        }
        
        target.addObserver(self, forKeyPath: keyPath, options: [.old, .new], context: nil)
        
        isObserving = true
        
        if shouldRetainTarget {
            retainedTarget = target
        }
    }
    
    private func stopObservation() {
        guard isObserving else {
            return
        }
        
        target.removeObserver(self, forKeyPath: keyPath)
        
        isObserving = false
        retainedTarget = nil
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change else {
            return
        }
        
        let oldValue = change[NSKeyValueChangeKey.oldKey] as! ValueType
        let newValue = change[NSKeyValueChangeKey.newKey] as! ValueType
        let valueChange = ValueChange(oldValue: oldValue, newValue: newValue)
        publish(valueChange)
    }
    
    // MARK: Event Handlers
    
    /// The event handlers to be invoked when the dynamic property updates its value.
    public var eventHandlers: [EventHandlerToken: EventHandler<ValueChange<ValueType>>] = [:]
    
    /// Invoked when an event handler is added.
    public func didAddEventHandler() {
        startObservation()
    }
    
    /// Invoked when an event handler is removed.
    public func didRemoveEventHandler() {
        if eventHandlers.isEmpty {
            stopObservation()
        }
    }
    
    // MARK: Lock
    
    /// The lock used for operations related to event handlers and event publishing.
    public let lock = NSRecursiveLock("com.blendle.hanson.dynamic-property")
    
}

public extension NSObject {
    
    /// Creates and returns a dynamic property usable to observe a property on the receiver.
    ///
    /// - Parameters:
    ///   - keyPath: The key path of the property to observe.
    ///   - type: The type of the property to observe.
    ///   - shouldRetainTarget: Whether or not the target should be retained while the dynamic property is being observed. Defaults to true.
    /// - Returns: An initialized dynamic property.
    public func dynamicProperty<ValueType>(keyPath: String, type: ValueType.Type, shouldRetainTarget: Bool = true) -> DynamicProperty<ValueType> {
        return DynamicProperty(target: self, keyPath: keyPath, type: type, shouldRetainTarget: shouldRetainTarget)
    }
    
}
