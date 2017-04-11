//
//  ValueChange.swift
//  Hanson
//
//  Created by Joost van Dijk on 24/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

/// The `ValueChange` structure represents an event that contains an observable's old and new values.
public struct ValueChange<Value> {
    
    /// The observable's old value.
    public let oldValue: Value
    
    /// The observable's new value.
    public let newValue: Value
    
}
