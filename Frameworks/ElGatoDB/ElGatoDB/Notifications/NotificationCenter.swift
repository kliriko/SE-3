//
//  NotificationCenter.swift
//  ElGatoDB
//
//  Created by Володимир on 11.10.2025.
//

import Foundation
import UserNotifications

class NotificationCenter {
    func scheduleLocalNotification(title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date), repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(
         identifier: uuidString,
         content: content,
         trigger: trigger
        )
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelNotification(taskName: String) {
        var idsToCancel: [String] = []
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            idsToCancel = requests.filter { req in
                req.content.title == taskName
            }.map { $0.identifier}
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToCancel)
        }
    }
    
    func listPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Pending notifications: \(requests)")
        }
    }
}
