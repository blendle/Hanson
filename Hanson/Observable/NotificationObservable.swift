//
//  NotificationObservable.swift
//  Hanson
//
//  Created by Joost van Dijk on 26/05/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

/// The `NotificationObservable` class represents an observable Notification. It acts as a wrapper around the NotificationCenter API.
public class NotificationObservable: EventPublisher {
    
    /// An alias for the event type that the notification observable publishes.
    public typealias Event = Notification
    
    /// The notification center to observe for notifications.
    public let notificationCenter: NotificationCenter
    
    /// The name of the notification to observe.
    public let notificationName: Notification.Name
    
    /// The object whose notifications should be observed, or nil if notifications from all senders should be observed.
    public let notificationObject: Any?
    
    /// Initializes the notification observable.
    ///
    /// - Parameters:
    ///   - notificationCenter: The notification center to observe for notifications.
    ///   - notificationName: The name of the notification to observe.
    ///   - notificationObject: The object whose notifications should be observed, or nil if notifications from all senders should be observed.
    public init(notificationCenter: NotificationCenter, notificationName: Notification.Name, notificationObject: Any? = nil) {
        self.notificationCenter = notificationCenter
        self.notificationName = notificationName
        self.notificationObject = notificationObject
    }
    
    deinit {
        stopObservation()
    }
    
    // MARK: Notification Observation
    
    internal private(set) var isObserving = false
    
    private func startObservation() {
        guard isObserving == false else {
            return
        }
        
        notificationCenter.addObserver(self, selector: #selector(didReceive(_:)), name: notificationName, object: notificationObject)
        
        isObserving = true
    }
    
    private func stopObservation() {
        guard isObserving else {
            return
        }
        
        notificationCenter.removeObserver(self, name: notificationName, object: notificationObject)
        
        isObserving = false
    }
    
    @objc private func didReceive(_ notification: Notification) {
        publish(notification)
    }
    
    // MARK: Event Handlers
    
    /// The event handlers to be invoked when the dynamic observable updates its value.
    public var eventHandlers: [EventHandlerToken: EventHandler<Notification>] = [:]
    
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
    public let lock = NSRecursiveLock("com.blendle.hanson.notification-observable")
    
}

public extension NotificationCenter {
    
    /// Creates and returns a notification observable for the receiving notification center.
    ///
    /// - Parameters:
    ///   - notificationName: The name of the notification to observe.
    ///   - object: The object whose notifications should be observed, or nil if notifications from all senders should be observed.
    /// - Returns: A notification observable for the receiving notification center.
    public func observable(for notificationName: Notification.Name, object: Any? = nil) -> NotificationObservable {
        return NotificationObservable(notificationCenter: self, notificationName: notificationName, notificationObject: object)
    }
    
}
