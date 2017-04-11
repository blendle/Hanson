//
//  Observation.swift
//  Hanson
//
//  Created by Joost van Dijk on 23/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

/// The `Observation` class represents an observation from an observer to an event publisher.
public struct Observation {
    
    /// Alias for the unobserve handler.
    internal typealias UnobserveHandler = () -> Void
    
    /// The unique identifier associated with this observation.
    internal let uuid = UUID()
    
    /// The handler to invoke when the observation should be removed.
    internal let unobserveHandler: UnobserveHandler
    
    /// Initializes the observation.
    ///
    /// - Parameters:
    ///   - unobserveHandler: The handler to invoke when the observation should be removed.
    internal init(unobserveHandler: @escaping UnobserveHandler) {
        self.unobserveHandler = unobserveHandler
    }
    
}

extension Observation: Hashable {
    
    public var hashValue: Int {
        return uuid.hashValue
    }
    
    public static func ==(lhs: Observation, rhs: Observation) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
}
