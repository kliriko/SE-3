//
//  InboxViewModel.swift
//  ElGatoDB
//
//  Created by Володимир on 13.10.2025.
//

import Foundation
import SwiftUI
import Combine
import CoreData

class InboxViewModel: ObservableObject {
    var context: NSManagedObjectContext?
    @Published var incomingNotifications: [IncomingNotification] = []
    
    func initContext(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchNotifications() {
        guard let context = context else {
            print("Failed to fetch. No core data context")
            return
        }
        let fetchRequest: NSFetchRequest<MyNotification> = MyNotification.fetchRequest()
        do {
            incomingNotifications = try context.fetch(fetchRequest).map { IncomingNotification($0) }
            print(incomingNotifications)
        } catch {
            print("Failed to fetch notifications: \(error)")
        }
    }
    
    func updateNotification(title: String, isAccepted: Bool) {
        guard let context = context else { return }
        let fetchRequest: NSFetchRequest<MyNotification> = MyNotification.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        guard let notification = try! context.fetch(fetchRequest).first else {
            print("Failed to fetch notification with title \(title)")
            return
        }
        
        notification.setValue(isAccepted ? "accepted" : "declined", forKey: "status")
        print(notification.status)
        do {
            try context.save()
        } catch {
            print("failed to save notification")
        }
        
        
        guard let notification = try! context.fetch(fetchRequest).first else {
            print("Failed to fetch notification with title \(title)")
            return
        }
        print(notification.status)
    }
}
