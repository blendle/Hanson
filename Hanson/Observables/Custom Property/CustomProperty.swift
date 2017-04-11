//
//  CustomProperty.swift
//  Hanson
//
//  Created by Joost van Dijk on 27/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

/// The `CustomProperty` class represents a property with a custom setter.
/// This property can be used to wrap a normal Swift property into a property that can act as a bindable.
/// The `CustomProperty` does not implement a getter and does not publish events.
public class CustomProperty<Target: AnyObject, Value>: Bindable {
    
    /// Alias for the setter closure.
    public typealias Setter = (Target, Value) -> Void
    
    /// The target that owns the property that is being wrapped.
    public unowned let target: Target
    
    /// The setter that will be invoked once a new value is received.
    public let setter: Setter
    
    /// Initializes the custom property.
    ///
    /// - Parameters:
    ///   - target: The target that owns the property that is being wrapped.
    ///   - setter: The setter that will be invoked once a new value is received.
    public init(target: Target, setter: @escaping Setter) {
        self.target = target
        self.setter = setter
    }
    
    // MARK: Value
    
    public var value: Value {
        get {
            fatalError("Retrieving a value from a custom property is not supported.")
        }
        
        set {
            setter(target, newValue)
        }
    }
    
}

public extension ObservationManager {
    
    /// Binds a value from an event publisher to a target and setter.
    /// This is a convenience method to bind an event publisher to a custom property.
    ///
    /// - Parameters:
    ///   - eventPublisher: The event publisher to observe for value changes.
    ///   - target: The target that owns the property that is being wrapped.
    ///   - setter: The setter that is invoked to change the wrapped property's value.
    /// - Returns: The observation that has been created.
    @discardableResult
    public func bind<E: EventPublisher & Bindable, Target: AnyObject>(_ eventPublisher: E, to target: Target, setter: @escaping CustomProperty<Target, E.Value>.Setter) -> Observation {
        let customProperty = CustomProperty(target: target, setter: setter)
        let observation = bind(eventPublisher, to: customProperty)
        
        return observation
    }
    
}

public extension Observer {
    
    /// Binds a value from an event publisher to a target and setter.
    /// This is a convenience method to bind an event publisher to a custom property.
    ///
    /// - Parameters:
    ///   - eventPublisher: The event publisher to observe for value changes.
    ///   - target: The target that owns the property that is being wrapped.
    ///   - setter: The setter that is invoked to change the wrapped property's value.
    /// - Returns: The observation that has been created.
    @discardableResult
    public func bind<E: EventPublisher & Bindable, Target: AnyObject>(_ eventPublisher: E, to target: Target, setter: @escaping CustomProperty<Target, E.Value>.Setter) -> Observation {
        return observationManager.bind(eventPublisher, to: target, setter: setter)
    }
    
}
