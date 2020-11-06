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
    ///   - eventScheduler: The scheduler to be used by the event publisher.
    ///   - eventHandler: The handler to invoke when an event is published.
    /// - Returns: The observation that has been created.
    @discardableResult
    func observe<E: EventPublisher>(_ eventPublisher: E, with eventScheduler: EventScheduler = CurrentThreadScheduler(), eventHandler: @escaping EventHandler<E.Event>) -> Observation {
        return observationManager.observe(eventPublisher, with: eventScheduler, eventHandler: eventHandler)
    }
    
    /// Binds the value of a bindable event publisher to a bindable.
    ///
    /// - Parameters:
    ///   - eventPublisher: The event publisher to observe for value changes.
    ///   - eventScheduler: The scheduler to be used by the event publisher and for setting the initial value.
    ///   - bindable: The bindable to update with the value changes of the event publisher.
    /// - Returns: The observation that has been created.
    @discardableResult
    func bind<E: EventPublisher & Bindable, B: Bindable>(_ eventPublisher: E, with eventScheduler: EventScheduler = CurrentThreadScheduler(), to bindable: B) -> Observation where E.Value == B.Value {
        return observationManager.bind(eventPublisher, with: eventScheduler, to: bindable)
    }
    
    /// Removes an observation.
    ///
    /// - Parameter observation: The observation to remove.
    func unobserve(_ observation: Observation) {
        observationManager.unobserve(observation)
    }
    
    /// Removes all observations.
    func unobserveAll() {
        observationManager.unobserveAll()
    }
    
}
