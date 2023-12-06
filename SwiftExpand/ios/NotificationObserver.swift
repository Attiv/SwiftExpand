//
//  NotificationObserver.swift
//  Ysp
//
//  Created by Vitta on 2023/11/30.
//

import Foundation
public class NotificationObserver {
    private var observers: [NSObjectProtocol] = []

    deinit {
        removeAllObservers()
    }

    public init() {}

    public func addObserver(forName name: Notification.Name, using block: @escaping (Notification) -> Void) -> NotificationObserver {
        let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { [weak self] notification in
            block(notification)
        }
        observers.append(observer)
        return self
    }

    public func removeAllObservers() {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()
    }
}
