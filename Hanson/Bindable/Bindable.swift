//
//  Bindable.swift
//  Hanson
//
//  Created by Joost van Dijk on 26/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

/// Types conforming to the `Bindable` protocol can be updated with a new value when an event is published from an `EventPublisher`. Both ends of a binding should implement the `Bindable` protocol, as the receiving bindable will be set to the value of the source bindable when the binding is made.
public protocol Bindable: class {
    
    /// The type of value of the bindable.
    associatedtype Value
    
    /// The value of the bindable.
    var value: Value { get set }
    
}
