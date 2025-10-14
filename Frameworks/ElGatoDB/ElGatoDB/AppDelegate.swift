//
//  AppDelegate.swift
//  ElGatoDB
//
//  Created by Володимир on 13.10.2025.
//

import Foundation
import UIKit
import UserNotifications
import CoreData
import SwiftUI
import NotificationCenter

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    @Environment(\.managedObjectContext) var managedObjectContext
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
                return
            }

            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                    print("Registered for remote notifications.")
                }
            } else {
                print("Notification permission not granted.")
            }
        }

        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
     ) {
        // MARK: Parse this shit
        guard
            let aps = userInfo["aps"] as? [String: Any],
            let alert = aps["alert"] as? [String: Any],
            let title = alert["title"] as? String,
            let body = alert["body"] as? String
        else {
            print("Notification payload missing required fields.")
            completionHandler(.noData)
            return
        }
        guard let dueDateString = userInfo["dueDate"] as? String else {
            print("No dueDate found in notification.")
            completionHandler(.noData)
            return
        }
        let formatter = ISO8601DateFormatter()
        guard let dueDate = formatter.date(from: dueDateString) else {
            print("Unable to decode dueDate: \(dueDateString)")
            completionHandler(.noData)
            return
        }
        
        // MARK: Create core data object
        let context = PersistenceController.shared.container.viewContext
        let notification = Notification(context: context)
        notification.status = "pending"
        notification.title = title
        notification.dueDate = dueDate
        do {
            try context.save()
            print("saved context")
        } catch { print("o no la policia") }
        
        completionHandler(.newData)
     }
     func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
     ) {
        completionHandler([.banner, .sound, .badge])
     }
}
