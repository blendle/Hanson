//
//  MainThreadScheduler.swift
//  Hanson
//
//  Created by Bram Schulting on 05/11/2020.
//  Copyright © 2020 Blendle. All rights reserved.
//

import Foundation

/// An `EventScheduler` that makes sure events are scheduled from the main thread, regardless from which thread it is
/// called. This scheduler is useful when performing UI changes while observing a value that can be changed from a
/// background thread.
public class MainThreadScheduler: EventScheduler {

    public init() {

    }

    public func scheduleEvent(closure: @escaping () -> Void) {
        // If we're already on the main thread, we can call the closure immediately
        if Thread.isMainThread {
            return closure()
        }

        DispatchQueue.main.async {
            closure()
        }
    }

}
