//
//  NSRecursiveLock+Helpers.swift
//  Hanson
//
//  Created by Joost van Dijk on 02/02/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

internal extension NSRecursiveLock {
    
    /// Initializes the recursive lock.
    ///
    /// - Parameter name: The name associated with the lock.
    internal convenience init(_ name: String) {
        self.init()
        
        self.name = name
    }
    
}
