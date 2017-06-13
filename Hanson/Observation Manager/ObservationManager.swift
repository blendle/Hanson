//
//  ObservationManager.swift
//  Hanson
//
//  Created by Joost van Dijk on 23/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

/// The `ObservationManager` class manages observations made from an observer.
public class ObservationManager {
    
    internal var observations: [Observation] = []
    
    internal let lock = NSRecursiveLock("com.blendle.hanson.observation-manager")
    
    public init() {
        
    }
    
    deinit {
        unobserveAll()
    }
    
    /// Observes an event publisher for events.
    ///
    /// - Parameters:
    ///   - eventPublisher: The event publisher to observe.
    ///   - eventHandler: The handler to invoke when an event is published.
    /// - Returns: The observation that has been created.
    @discardableResult
    public func observe<E: EventPublisher>(_ eventPublisher: E, eventHandler: @escaping EventHandler<E.Event>) -> Observation {
        lock.lock()
        defer { lock.unlock() }
        
        let eventHandlerToken = eventPublisher.addEventHandler(eventHandler)
        let unobserveHandler = { eventPublisher.removeEventHandler(with: eventHandlerToken) }
        
        let observation = Observation(unobserveHandler: unobserveHandler)
        observations.append(observation)
        
        return observation
    }
    
    /// Binds the value of a bindable event publisher to a bindable.
    ///
    /// - Parameters:
    ///   - eventPublisher: The event publisher to observe for value changes.
    ///   - bindable: The bindable to update with the value changes of the event publisher.
    /// - Returns: The observation that has been created.
    @discardableResult
    public func bind<E: EventPublisher & Bindable, B: Bindable>(_ eventPublisher: E, to bindable: B) -> Observation where E.Value == B.Value {
        bindable.value = eventPublisher.value
        
        let observation = observe(eventPublisher) { [unowned eventPublisher] event in
            bindable.value = eventPublisher.value
        }
        
        return observation
    }
    
    /// Removes an observation.
    ///
    /// - Parameter observation: The observation to remove.
    public func unobserve(_ observation: Observation) {
        lock.lock()
        defer { lock.unlock() }
        
        guard let index = observations.index(of: observation) else {
            return
        }
        
        observation.unobserveHandler()
        observations.remove(at: index)
    }
    
    /// Removes all observations.
    public func unobserveAll() {
        lock.lock()
        defer { lock.unlock() }
        
        observations.forEach { $0.unobserveHandler() }
        observations.removeAll()
    }
    
}
