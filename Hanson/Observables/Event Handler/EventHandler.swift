//
//  EventHandler.swift
//  Hanson
//
//  Created by Joost van Dijk on 23/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

/// An alias for a closure that handles a published event.
public typealias EventHandler<Event> = (Event) -> Void

/// The `EventHandlerToken` structure represents a unique token used to identify and remove an event handler.
public struct EventHandlerToken: Hashable {
    
    fileprivate let uuid = UUID()
    
    public var hashValue: Int {
        return uuid.hashValue
    }
    
    public static func ==(lhs: EventHandlerToken, rhs: EventHandlerToken) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
}
