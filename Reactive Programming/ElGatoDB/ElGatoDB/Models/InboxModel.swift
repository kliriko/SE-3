//
//  InboxModel.swift
//  ElGatoDB
//
//  Created by Володимир on 13.10.2025.
//

import Foundation

enum NotificationStatus: String {
    case accepted, declined, pending
}

struct IncomingNotification: Identifiable {
    var task: MyTask
    var status: NotificationStatus!
    var id: String = UUID().uuidString
    var title: String
    
    init (_ notification: MyNotification) {
        self.task = MyTask(notification: notification)
        self.title = notification.title
        self.status = NotificationStatus(rawValue: notification.status)
    }
}

