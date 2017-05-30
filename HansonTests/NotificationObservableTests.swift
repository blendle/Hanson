//
//  NotificationObservableTests.swift
//  Hanson
//
//  Created by Joost van Dijk on 26/05/2017.
//  Copyright © 2017 Blendle. All rights reserved.
//

import XCTest
@testable import Hanson

class NotificationObservableTests: XCTestCase {
    
    func testObservingNotification() {
        let notificationCenter = NotificationCenter()
        let notificationName = Notification.Name(rawValue: "TestNotification")
        
        let observable = NotificationObservable(notificationCenter: notificationCenter,
                                                notificationName: notificationName)
        
        var notificationReceived = false
        observable.addEventHandler { notification in
            notificationReceived = true
        }
        
        // Verify that we haven't received a notification yet.
        XCTAssertFalse(notificationReceived)
        
        // Post a sample notification with the registered name.
        notificationCenter.post(name: notificationName, object: nil)
        
        // Verify that the notification has been received.
        XCTAssertTrue(notificationReceived)
    }
    
    func testObservingWhenEventHandlersAreAdded() {
        let notificationCenter = NotificationCenter()
        let notificationName = Notification.Name(rawValue: "TestNotification")
        
        let observable = NotificationObservable(notificationCenter: notificationCenter,
                                                notificationName: notificationName)
        
        // Verify that the observer is not observing when no event handlers are added.
        XCTAssertFalse(observable.isObserving)
        
        // After adding an event handler, the observer should be observing.
        let firstEventHandlerToken = observable.addEventHandler { _ in }
        XCTAssertTrue(observable.isObserving)
        
        // After adding another event handler, the observer should still be observing.
        let secondEventHandlerToken = observable.addEventHandler { _ in }
        XCTAssertTrue(observable.isObserving)
        
        // After removing the first event handler, the observer should still be observing.
        observable.removeEventHandler(with: firstEventHandlerToken)
        XCTAssertTrue(observable.isObserving)
        
        // After removing the second and last event handler, the observer should stop observing.
        observable.removeEventHandler(with: secondEventHandlerToken)
        XCTAssertFalse(observable.isObserving)
    }
    
}
