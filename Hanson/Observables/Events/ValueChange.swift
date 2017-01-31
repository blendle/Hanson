//
//  ValueChange.swift
//  Hanson
//
//  Created by Joost van Dijk on 24/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

/// The `ValueChange` structure represents an event sent from a property, containing the property's old and new values.
public struct ValueChange<ValueType> {
    
    /// The property's old value.
    public let oldValue: ValueType
    
    /// The property's new value.
    public let newValue: ValueType
    
}
