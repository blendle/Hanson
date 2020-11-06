//
//  EventScheduler.swift
//  Hanson
//
//  Created by Bram Schulting on 05/11/2020.
//  Copyright © 2020 Blendle. All rights reserved.
//

import Foundation

/// Types conforming to `EventScheduler` can be used to schedule events for specific moments. By default Hanson uses an
/// instance of `CurrentThreadScheduler` which publishes events immediately, on the thread the process is already on at
/// that moment (which is the thread were the observable value is changed). Hanson also provides the
/// `MainThreadScheduler` which ensures the event is published on the main thread, regardless of from which thread the
/// value is changed.
public protocol EventScheduler {

    /// Method that will be called by the `EventPublisher` when it wants to publish an event.
    /// - Parameter closure: The closure in which the event will be sent.
    func scheduleEvent(closure: @escaping () -> Void)

}
