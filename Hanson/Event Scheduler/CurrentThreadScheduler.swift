//
//  CurrentThreadScheduler.swift
//  Hanson
//
//  Created by Bram Schulting on 05/11/2020.
//  Copyright © 2020 Blendle. All rights reserved.
//

import Foundation

/// An `EventScheduler` that schedules events immediately in the current thread. Events will be published from the
/// thread the scheduler is called from (which is the thread the observable value is changed from).
public class CurrentThreadScheduler: EventScheduler {

    public init() {
        
    }

    public func scheduleEvent(closure: @escaping () -> Void) {
        closure()
    }

}
