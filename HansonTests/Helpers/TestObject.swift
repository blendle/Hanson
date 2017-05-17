//
//  TestObject.swift
//  Hanson
//
//  Created by Joost van Dijk on 24/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

class TestObject: NSObject {
    
    public dynamic var value: String
    
    public init(value: String) {
        self.value = value
        
        super.init()
    }
    
}
