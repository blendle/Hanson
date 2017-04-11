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
