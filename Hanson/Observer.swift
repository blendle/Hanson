//
//  Observer.swift
//  Hanson
//
//  Created by Joost van Dijk on 23/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

/// Types conforming to the `Observer` protocol can make and remove observations.
public protocol Observer {
    
    /// The observation manager that manages the observations made by the receiver.
    var observationManager: ObservationManager { get }
    
}

public extension Observer {
    
    /// Observes an observable for events.
    ///
    /// - Parameters:
    ///   - observable: The observable to observe.
    ///   - eventHandler: The handler to invoke when an event is published.
    /// - Returns: The observation that has been created.
    @discardableResult
    public func observe<O: Observable>(_ observable: O, eventHandler: @escaping EventHandler<O.EventType>) -> Observation {
        return observationManager.observe(observable, eventHandler: eventHandler)
    }
    
    /// Binds the value of a bindable observable to an observable.
    ///
    /// - Parameters:
    ///   - observable: The observable to observe for value changes.
    ///   - bindable: The bindable to update with the value changes of the observable.
    /// - Returns: The observation that has been created.
    @discardableResult
    public func bind<O: Observable & Bindable, B: Bindable>(_ observable: O, to bindable: B) -> Observation where O.ValueType == B.ValueType {
        return observationManager.bind(observable, to: bindable)
    }
    
    /// Removes an observation.
    ///
    /// - Parameter observation: The observation to remove.
    public func unobserve(_ observation: Observation) {
        observationManager.unobserve(observation)
    }
    
    /// Removes all observations.
    public func unobserveAll() {
        observationManager.unobserveAll()
    }
    
}
