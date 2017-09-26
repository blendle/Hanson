//
//  EventPublisher.swift
//  Hanson
//
//  Created by Joost van Dijk on 26/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

/// Types conforming to the `EventPublisher` protocol can publish and be observed for events.
public protocol EventPublisher: class {
    
    /// The type of event that the event publisher publishes.
    associatedtype Event
    
    /// The event handlers that should be invoked when an event is published.
    var eventHandlers: [EventHandlerToken: EventHandler<Event>] { get set }
    
    /// Adds an event handler.
    ///
    /// - Parameter eventHandler: The event handler to invoke when an event is published.
    /// - Returns: A token, usable to identify and remove the event handler later on.
    @discardableResult
    func addEventHandler(_ eventHandler: @escaping EventHandler<Event>) -> EventHandlerToken
    
    /// Invoked when an event handler has been removed.
    /// This provides an opportunity to set up resources used for publishing events.
    func didAddEventHandler()
    
    /// Removes an event handler.
    ///
    /// - Parameter eventHandlerToken: The token associated with the event handler that should be removed.
    func removeEventHandler(with eventHandlerToken: EventHandlerToken)
    
    /// Invoked when an event handler has been removed.
    /// This provides an opportunity to clean up resources used for publishing events.
    func didRemoveEventHandler()
    
    /// Publishes an event to the registered event handlers.
    ///
    /// - Parameter event: The event to publish.
    func publish(_ event: Event)
    
    /// The lock used for operations related to event handlers and event publishing.
    var lock: NSRecursiveLock { get }
    
}

public extension EventPublisher {
    
    public func publish(_ event: Event) {
        lock.lock()
        defer { lock.unlock() }
        
        eventHandlers.forEach { _, eventHandler in
            eventHandler(event)
        }
    }
    
    @discardableResult
    public func addEventHandler(_ eventHandler: @escaping EventHandler<Event>) -> EventHandlerToken {
        lock.lock()
        defer { lock.unlock() }
        
        let eventHandlerToken = EventHandlerToken()
        eventHandlers[eventHandlerToken] = eventHandler
        
        didAddEventHandler()
        
        return eventHandlerToken
    }
    
    public func didAddEventHandler() {
        
    }
    
    public func removeEventHandler(with eventHandlerToken: EventHandlerToken) {
        lock.lock()
        defer { lock.unlock() }
        
        eventHandlers.removeValue(forKey: eventHandlerToken)
        
        didRemoveEventHandler()
    }
    
    public func didRemoveEventHandler() {
        
    }
    
}
