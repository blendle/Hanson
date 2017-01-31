//
//  Observation.swift
//  Hanson
//
//  Created by Joost van Dijk on 23/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

/// The `Observation` class represents an observation from an observer to an observable.
public class Observation {
    
    /// The unique identifier associated with this observation.
    internal let uuid = UUID()
    
    /// The observable that is being observed for events.
    public let observable: AnyObservable
    
    /// The event handler token used to register the event handler on the observable.
    public let eventHandlerToken: EventHandlerToken
    
    /// Initializes the observation.
    ///
    /// - Parameters:
    ///   - observable: The observable that will be observed for events.
    ///   - eventHandlerToken: The event handler token used to register the event handler on the observable.
    public init<O: Observable>(observable: O, eventHandlerToken: EventHandlerToken) {
        self.observable = observable
        self.eventHandlerToken = eventHandlerToken
    }
    
}

extension Observation: Hashable {
    public var hashValue: Int {
        return uuid.hashValue
    }
    
    public static func ==(lhs: Observation, rhs: Observation) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
