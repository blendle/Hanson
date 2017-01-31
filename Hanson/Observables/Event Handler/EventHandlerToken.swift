//
//  EventHandlerToken.swift
//  Hanson
//
//  Created by Joost van Dijk on 23/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

/// The `EventHandlerToken` structure represents a unique token used to identify and remove an event handler.
public struct EventHandlerToken {
    fileprivate let uuid = UUID()
}

extension EventHandlerToken: Hashable {
    public var hashValue: Int {
        return uuid.hashValue
    }
}

public func ==(lhs: EventHandlerToken, rhs: EventHandlerToken) -> Bool {
    return lhs.uuid == rhs.uuid
}
