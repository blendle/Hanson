//
//  NSObject+Observer.swift
//  Hanson
//
//  Created by Joost van Dijk on 26/01/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import Foundation

extension NSObject: Observer {
    
    private struct AssociatedKeys {
        static var ObservationManager = "hanson_observationManager"
    }
    
    public var observationManager: ObservationManager {
        get {
            if let observationManager = objc_getAssociatedObject(self, &AssociatedKeys.ObservationManager) as? ObservationManager {
                return observationManager
            }
            
            let observationManager = ObservationManager()
            objc_setAssociatedObject(self, &AssociatedKeys.ObservationManager, observationManager, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            return observationManager
        }
    }
    
}
