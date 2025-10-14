//
//  InboxModel.swift
//  ElGatoDB
//
//  Created by Володимир on 13.10.2025.
//

import Foundation

enum NotificationStatus {
    case accepted, declined, pending
}

struct IncomingNotification: Identifiable {
    var task: Task
    var status: NotificationStatus = .pending
    var id: String
    
    init (_ notification: Notification) {
        self.task = Task(notification: notification)
        self.id = notification.title
    }
}
