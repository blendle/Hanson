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
    
    /// Observes an event publisher for events.
    ///
    /// - Parameters:
    ///   - eventPublisher: The event publisher to observe.
    ///   - eventHandler: The handler to invoke when an event is published.
    /// - Returns: The observation that has been created.
    @discardableResult
    public func observe<E: EventPublisher>(_ eventPublisher: E, eventHandler: @escaping EventHandler<E.Event>) -> Observation {
        return observationManager.observe(eventPublisher, eventHandler: eventHandler)
    }
    
    /// Binds the value of a bindable event publisher to a bindable.
    ///
    /// - Parameters:
    ///   - eventPublisher: The event publisher to observe for value changes.
    ///   - bindable: The bindable to update with the value changes of the event publisher.
    /// - Returns: The observation that has been created.
    @discardableResult
    public func bind<E: EventPublisher & Bindable, B: Bindable>(_ eventPublisher: E, to bindable: B) -> Observation where E.Value == B.Value {
        return observationManager.bind(eventPublisher, to: bindable)
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
