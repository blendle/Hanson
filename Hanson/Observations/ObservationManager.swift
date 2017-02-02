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
    
    deinit {
        unobserveAll()
    }
    
    /// Observes an observable for events.
    ///
    /// - Parameters:
    ///   - observable: The observable to observe.
    ///   - eventHandler: The handler to invoke when an event is published.
    /// - Returns: The observation that has been created.
    @discardableResult
    public func observe<O: Observable>(_ observable: O, eventHandler: @escaping EventHandler<O.EventType>) -> Observation {
        lock.lock()
        defer { lock.unlock() }
        
        let eventHandlerToken = observable.addEventHandler(eventHandler)
        let unobserveHandler = { observable.removeEventHandler(with: eventHandlerToken) }
        
        let observation = Observation(observable: observable, unobserveHandler: unobserveHandler)
        observations.append(observation)
        
        return observation
    }
    
    /// Binds the value of a bindable observable to an observable.
    ///
    /// - Parameters:
    ///   - observable: The observable to observe for value changes.
    ///   - bindable: The bindable to update with the value changes of the observable.
    /// - Returns: The observation that has been created.
    @discardableResult
    public func bind<O: Observable & Bindable, B: Bindable>(_ observable: O, to bindable: B) -> Observation where O.ValueType == B.ValueType {
        bindable.value = observable.value
        
        let observation = observe(observable) { [unowned observable] event in
            bindable.value = observable.value
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
