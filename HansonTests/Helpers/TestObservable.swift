//
//  TestObservable.swift
//  Hanson
//
//  Created by Joost van Dijk on 26/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation
import Hanson

class TestObservable: Observable {
    typealias EventType = String
    
    var eventHandlers: [EventHandlerToken: EventHandler<String>] = [:]
}
